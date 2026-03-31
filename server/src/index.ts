import { EndBehaviorType, joinVoiceChannel, VoiceConnectionStatus } from "@discordjs/voice";
import { DeepgramClient } from "@deepgram/sdk";
import prism from "prism-media";
import { Client, Events, GatewayIntentBits } from "discord.js";
import "dotenv/config";
import { WebSocketServer } from "ws";

(async function () {
  const client = new Client({
    intents: [
      GatewayIntentBits.Guilds,
      GatewayIntentBits.GuildMessages,
      GatewayIntentBits.GuildMessageTyping,
      GatewayIntentBits.GuildMessageReactions,
      GatewayIntentBits.GuildMessagePolls,
      GatewayIntentBits.MessageContent,
      GatewayIntentBits.GuildVoiceStates,
    ],
  });
  const wss = new WebSocketServer({ port: 5733 });

  let resolveReady: (value: undefined) => void = () => {};
  const ready = new Promise(resolve => resolveReady = resolve);

  const sendAll = (msg: string) => {
    console.log('heard', msg)
    for (const ws of wss.clients) {
      ws.send(msg);
    }
  }

  wss.on("connection", function connection(ws) {
    ws.send("hello");
  });

  client.on(Events.ClientReady, (readyClient) => {
    console.log(`Logged in as ${readyClient.user.tag}!`);
    resolveReady(undefined);
  });

  client.on(Events.MessageCreate, async (message) => {
    if (message.channelId !== process.env.CHANNEL) return;
    if (!message.content) return;

    sendAll(`{${message.author.id}}${message.content}`)
  });

  client.login(process.env.TOKEN);

  const guild = await client.guilds.fetch(process.env.GUILD!);
  if (!guild) {
    console.log("no guild");
    return;
  }
  const voiceChannel = await guild.channels.fetch(process.env.CHANNEL!);
  if (!voiceChannel) {
    console.log("no channel");
    return;
  }

  await ready

  const connection = joinVoiceChannel({
    channelId: voiceChannel.id,
    guildId: voiceChannel.guild.id,
    adapterCreator: voiceChannel.guild.voiceAdapterCreator,
    selfDeaf: false,
    selfMute: true,
  });

  // set DEEPGRAM_API_KEY in env
  const deepgram = new DeepgramClient();
  const connections = new Set<string>()

  connection.receiver.speaking.on("start", async (userId) => {
    if (connections.has(userId)) return;
    connections.add(userId);
    try {
      const opusStream = connection.receiver.subscribe(userId, {
        end: {
          behavior: EndBehaviorType.AfterSilence,
          duration: 1000,
        },
      });

      // opus to pcm
      const decoder = new prism.opus.Decoder({
        rate: 48000,
        channels: 2,
        frameSize: 960,
      });

      const chunks: Buffer[] = [];

      // save chunks
      decoder.on("data", (pcm) => {
        chunks.push(Buffer.from(pcm));
      });

      decoder.on("error", (err) => {
        console.warn("Decoder error:", err.message);
        connections.delete(userId)
        decoder.destroy()
        opusStream.destroy()
      });
      
      opusStream.pipe(decoder);

      opusStream.on("end", async () => {
        connections.delete(userId);
        decoder.destroy();
        if (chunks.length === 0) return;
        const pcmBuffer = Buffer.concat(chunks);

        // deepgram wants wav
        const { spawn } = await import('child_process');
        const ffmpeg = spawn('ffmpeg', [
          '-f', 's16le',
          '-ar', '48000',
          '-ac', '2',
          '-i', 'pipe:0',
          '-f', 'wav',
          'pipe:1',
        ]);

        // pipe in
        ffmpeg.stdin.write(pcmBuffer);
        ffmpeg.stdin.end();

        // pipe out
        const wavChunks: Buffer[] = [];
        ffmpeg.stdout.on('data', (chunk) => {
          wavChunks.push(chunk);
        });

        ffmpeg.on('close', async (code) => {
          if (code !== 0) {
            console.error(`ffmpeg exited with code ${code}`);
            return;
          }
          const wavBuffer = Buffer.concat(wavChunks);
          try {
            const response = await deepgram.listen.v1.media.transcribeFile(
              wavBuffer,
              {
                model: "base",
                language: "en",
              },
            );
            if (!('results' in response)) {
              console.error("Deepgram failed");
            } else {
              const transcript = response.results?.channels?.[0]?.alternatives?.[0]?.transcript?.trim?.();
              if (transcript) {
                sendAll(`{${userId}}[VOICE]${transcript}`);
              } else {
                console.log("No transcript returned by Deepgram.");
              }
            }
          } catch (err) {
            console.error("Deepgram transcription error:", err);
          }
        });
      });
    } catch (err) {
      connections.delete(userId);
    }
  });


})();
