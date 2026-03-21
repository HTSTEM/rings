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

  const sendAll = (msg: string) => {
    for (const ws of wss.clients) {
      ws.send(msg);
    }
  }

  wss.on("connection", function connection(ws) {
    ws.send("hello");
  });

  client.on(Events.ClientReady, (readyClient) => {
    console.log(`Logged in as ${readyClient.user.tag}!`);
  });

  client.on(Events.MessageCreate, async (message) => {
    if (message.channelId !== "1484684032422969355") return;
    if (!message.content) return;

    sendAll(message.content)
  });

  client.login(process.env.TOKEN);

  const guild = await client.guilds.fetch("282219466589208576");
  if (!guild) {
    console.log("no guild");
    return;
  }
  const voiceChannel = await guild.channels.fetch("1484686856556904560");
  if (!voiceChannel) {
    console.log("no channel");
    return;
  }

  const connection = joinVoiceChannel({
    channelId: voiceChannel.id,
    guildId: voiceChannel.guild.id,
    adapterCreator: voiceChannel.guild.voiceAdapterCreator,
    selfDeaf: false,
    selfMute: true,
  });

  console.log("Joined voice")

  // set DEEPGRAM_API_KEY in env
  const deepgram = new DeepgramClient();

  connection.receiver.speaking.on("start", async (userId) => {
    try {
      const opusStream = connection.receiver.subscribe(userId, {
        end: {
          behavior: EndBehaviorType.AfterSilence,
          duration: 1000 * 15, // billed per minute of activity, not # of spinups; seems to be no reason to keep this on longer than necessary
        },
      });

      // opus to pcm
      const decoder = new prism.opus.Decoder({
        rate: 48000,
        channels: 2,
        frameSize: 960,
      });
      opusStream.pipe(decoder);

      // the docs don't mention the "Authorization" param and idk why further auth would be required so im ignoring it
      const connectArgs: Omit<Parameters<typeof deepgram.listen.v1.connect>[0], 'Authorization'> = {
        model: "nova-3", // could omit to default to a cheaper/lesser model ("base"?)
        language: "en",
        punctuate: "true",
        interim_results: "true",
      }
      const dgConn = await deepgram.listen.v1.connect(connectArgs as any);

      dgConn.on("open", () => {
        console.log(`Listening to ${userId}`);
      });

      dgConn.on("message", (data) => {
        if (data.type === "Results" && data.channel && data.channel.alternatives && data.channel.alternatives[0]?.transcript) {
          const transcript = data.channel.alternatives[0].transcript?.trim?.();
          if (transcript) {
            // i'm not sure if this sends duplicates but i'm also not sure if it matters
            sendAll(`[VOICE]${transcript}`);
          }
        }
      });

      dgConn.connect();
      await dgConn.waitForOpen();

      decoder.on("data", (pcm) => {
        dgConn.socket.send(pcm);
      });

      opusStream.on("end", () => {
        decoder.destroy();
        dgConn.socket.close();
      });
    } catch (err) {
      // Ignore subscribe errors
    }
  });


})();
