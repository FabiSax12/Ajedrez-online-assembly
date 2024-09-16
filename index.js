import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
import { createClient } from "@supabase/supabase-js";

class Adapter {
  static toFileRow(row) {
    return `${row.player},${row.from},${row.to}`;
  }

  static toDbRow(row) {
    const [player, from, to, game_id] = row.split(",");
    return { player, from, to, game_id };
  }
}

const URL = "https://zeycferumtubqlaqjsax.supabase.co";
const API_KEY = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpleWNmZXJ1bXR1YnFsYXFqc2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQzODc0MDMsImV4cCI6MjAzOTk2MzQwM30.yre44KeowpW7fHu-kJfGlYnEVlPKZ9sZgUooZucl7WU`;

let ignoreDatabaseChange = false;
let ignoreFileChange = false;
let movesCount = 0;
let player_turn;
let restart = false;

const supabase = createClient(URL, API_KEY);

function getInstruction() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return null;

  const lines = file.split("\n");
  return lines[0].slice(0, -1);
}

async function register() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  console.log("Registering player...");
  const [_, username, password] = file.split("\r\n");
  const res = await supabase.from("users").insert([{ username, password }]);

  // Manejar errores
  if (res.error) {
    console.error(res.error);
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  console.log("Player registered successfully");
  writeFileSync("data.txt", "1"); // Responder a assembly
}

async function login() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  console.log("Logging player...");
  const [_, username, password] = file.split("\r\n");
  console.log(username, password);
  const { data, error } = await supabase
    .from("users")
    .select("id")
    .eq("username", username)
    .eq("password", password)
    .single();
  // Manejar errores
  if (error) {
    console.error(error);
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  if (!data) {
    console.error("Invalid credentials");
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  console.log("Player logged in successfully", data.id.toString());
  writeFileSync("data.txt", data.id.toString()); // Responder a assembly
}

async function createGame() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  const [_, meta] = file.split("\r\n");
  const game_id = meta.split(",")[0];
  const user_id = meta.split(",")[1];

  const res = await supabase.from("games").insert([{
    id: game_id,
    player_1: user_id
  }])

  // Manejar errores
  if (res.error) {
    console.error(res.error);
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  console.log("Game created successfully");

  const res2 = await supabase.from("users").update({
    online: true
  }).eq("id", user_id)

  // Manejar errores
  if (res2.error) {
    console.error(res2.error);
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  player_turn = 0;
  console.log("User online status updated successfully");
  writeFileSync("data.txt", "1"); // Responder a assembly

}

async function getGamesById() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  const [_, user_id] = file.split("\r\n");
  const res1 = await supabase.from("games").select("id").eq("player_1", user_id)
  const res2 = await supabase.from("games").select("id").eq("player_2", user_id)

  // Manejar errores
  if (res1.error || res2.error) {
    console.error(res1.error || res2.error);
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  const games = [...res1.data, ...res2.data].map(game => game.id).join("\r\n");

  console.log("Games found:", games);

  writeFileSync("data.txt", "1\r\n" + games); // Responder a assembly
}

async function joinGame() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  const [_, meta] = file.split("\n");
  const game_id = meta.split(",")[0];
  const user_id = meta.split(",")[1];

  // Ver cual de los 2 jugadores es
  const gameRes = await supabase.from("games").select("*").eq("id", game_id)

  // Manejar errores
  if (gameRes.error) {
    console.error(gameRes.error);
    return;
  }

  if (gameRes.data[0].player_1 == user_id) {
    player_turn = 0;
  }
  else if (gameRes.data[0].player_2 == null || gameRes.data[0].player_2 == user_id) {
    player_turn = 1;
    const res = await supabase.from("games").update({ player_2: user_id }).eq("id", game_id)
    // Manejar errores
    if (res.error) {
      console.error(res.error);
      writeFileSync("data.txt", "0"); // Responder a assembly
      return;
    }
  }

  console.log("Game joined successfully");

  const res2 = await supabase.from("users").update({
    online: true
  }).eq("id", user_id)

  // Manejar errores
  if (res2.error) {
    console.error(res2.error);
    writeFileSync("data.txt", "0"); // Responder a assembly
    return;
  }

  console.log("User online status updated successfully");

  // Traer los movimientos de la base de datos
  const movementsRes = await supabase.from("movements").select("*").eq("game_id", game_id)

  let fileRes = player_turn + "\r\n" + game_id + "," + user_id + "\r\n";
  for (const movement of movementsRes.data) {
    fileRes += Adapter.toFileRow(movement);

    if (fileRes.at(-1) == "\r") fileRes += "\n";
    else fileRes += "\r\n";
    movesCount++;
  }

  console.log(movementsRes)
  if (movementsRes.data.length == 0 || movementsRes.data.at(-1).player == player_turn) {
    ignoreDatabaseChange = false;
    ignoreFileChange = true;
  } else {
    ignoreDatabaseChange = true;
    ignoreFileChange = false;
  }

  writeFileSync("data.txt", fileRes); // Responder a assembly
}

async function playing() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  const [_, meta, ...moves] = file.split("\r\n");
  if (moves.at(-1) == "") moves.pop();
  const game_id = meta.split(",")[0];
  const player_id = meta.split(",")[1];

  // Definir turno para ver si empezamos viendo la base de datos o el archivo
  const gameDB = await supabase.from("games").select("*").eq("id", game_id)
  if (gameDB.error) {
    console.error(gameDB.error);
    return;
  }

  // Determinar si fue el turno del jugador o del oponente 0,1,0 => 1
  if (gameDB.data[0].player_1 == player_id) player_turn = 0;
  else player_turn = 1;

  console.log("Moves: ", moves);
  if (moves.length == 0) {
    if (player_turn == 0) {
      ignoreDatabaseChange = true;
      ignoreFileChange = false;
      console.log("Waiting for move...");
    } else {
      ignoreDatabaseChange = false;
      ignoreFileChange = true;
      console.log("Waiting for opponent's move...");
    }
  } else if (moves.at(-1).split(",")[0] == player_turn) {
    ignoreDatabaseChange = false;
    ignoreFileChange = true;
    console.log("Waiting for opponent's move...");
  } else if (moves.at(-1).split(",")[0] != player_turn) {
    ignoreDatabaseChange = true;
    ignoreFileChange = false;
    console.log("Waiting for move...");
  }

  console.log(
    "Turno: " + player_turn,
    "Database: " + !ignoreDatabaseChange,
    "File: " + !ignoreFileChange,
  )

  if (!ignoreFileChange) await watchDataFile();
  else if (!ignoreDatabaseChange) await watchDB(game_id);

  clearInterval(mainLoop);
  return;
}

async function watchDataFile() {
  console.log("Watching file...");

  const watcher = setInterval(async () => {
    let file;
    try {
      file = readFileSync("data.txt", "utf-8");
    } catch (e) {
      return;
    }

    const [_, meta, ...moves] = file.split("\r\n");
    if (moves.at(-1) == "") moves.pop();
    const lastMove = moves.at(-1);
    // Ver si el jugador se salió
    if (lastMove == "$") {
      writeFileSync("data.txt", "");
      clearInterval(watcher);
      mainLoop = setInterval(main, 2000);
      return;
    }

    console.log("Checking for new movements in file:", moves);

    if (moves.length === movesCount) return;  // Si no hay nuevos movimientos, salimos.
    if (!lastMove || lastMove.split(",")[0] != player_turn) return; // Si es del otro jugador vino de la base de datos

    // Procesar el nuevo movimiento
    console.log("New movement detected from file");

    const game_id = meta.split(",")[0];
    const [player, from, to] = lastMove ? lastMove.split(",") : [null, null, null];
    const res = await supabase.from("movements").insert({ game_id, player, from, to });

    if (res.error) return console.error(res.error);

    movesCount++;
    ignoreDatabaseChange = true;
    ignoreFileChange = true;
    console.log("Database updated. Moves: " + movesCount);

    clearInterval(watcher);
    watchDB(game_id);
  }, 2000);
}

async function watchDB(game_id) {
  console.log("Watching database...");

  const watcher = supabase
    .channel("movements")
    .on(
      "postgres_changes",
      { event: "INSERT", schema: "public", table: "movements", filter: `game_id=eq.${game_id}` },
      (payload) => dbPayloadHandler(payload, watcher)
    )
    .subscribe();
}

function dbPayloadHandler(payload, watcher) {
  const newRow = payload.new;
  console.log("New move detected from database:", newRow);

  const fileLine = Adapter.toFileRow(newRow);
  ignoreFileChange = true;

  try {
    appendFileSync("data.txt", fileLine + "\r\n");
  } catch (e) {
    dbPayloadHandler(payload)
    return;
  }
  movesCount++;
  console.log("Move added to file:", fileLine);

  ignoreDatabaseChange = true;
  console.log("File updated. Moves: " + movesCount);

  watcher.unsubscribe();
  watchDataFile();
}


async function main() {
  try {
    const instruction = getInstruction();
    if (!instruction || instruction.length <= 2) return;

    console.log("Instruction received:", instruction);

    if (instruction == "register") await register();
    else if (instruction == "login") await login();
    else if (instruction == "create") await createGame();
    else if (instruction == "games") await getGamesById();
    else if (instruction == "join") await joinGame();
    else if (instruction == "playing") await playing();
  } catch (e) {
    console.error(e);
    return;
  }
}

let mainLoop = setInterval(main, 2000);
