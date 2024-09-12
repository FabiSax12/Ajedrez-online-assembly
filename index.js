import { readFileSync, writeFileSync, appendFileSync, watch, watchFile } from "node:fs";
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
  const [_, username, password] = file.split("\n");
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
  const [_, username, password] = file.split("\n");
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

async function create_game() {
  const file = readFileSync("data.txt", "utf-8");
  if (!file) return;

  const [_, meta] = file.split("\n");
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

async function join_game() {
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

  let fileRes = "1\r\n" + game_id + "," + user_id + "\r\n";
  for (const movement of movementsRes.data) {
    fileRes += Adapter.toFileRow(movement) + "\r\n";
    movesCount++;
  }

  if (movementsRes.data.at(-1).player == player_turn) {
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

  const [_, meta, ...moves] = file.split("\n");
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

  if (moves.length == 0 || moves.at(-1).split(",")[0] != player_turn) {
    ignoreDatabaseChange = true;
    ignoreFileChange = false;
  } else {
    ignoreDatabaseChange = false;
    ignoreFileChange = true;
  }

  console.log(
    "Turno: " + player_turn,
    "Database: " + !ignoreDatabaseChange,
    "File: " + !ignoreFileChange,
  )

  await watchDataFile();
  await watchDB(game_id);

  clearInterval(mainLoop);
}

async function watchDataFile() {
  console.log("Watching file...");
  watchFile("data.txt", { interval: 1500 }, async (curr, prev) => {
    if (curr.mtime == prev.mtime) return;  // Si el archivo no ha cambiado, no hacemos nada.

    if (ignoreFileChange && !ignoreDatabaseChange) return;  // Si estamos ignorando cambios en el archivo y no en la BD, salimos.

    if (ignoreFileChange && ignoreDatabaseChange) {
      ignoreFileChange = false;  // Resetear el flag cuando ambos son true.
      console.log("Movimiento descargado desde el archivo exitosamente");
      console.log("Waiting for move...");
      return;
    }

    const file = readFileSync("data.txt", "utf-8");
    const [_, meta, ...moves] = file.split("\n");
    const lastMove = moves.at(-1) || moves.at(-2);

    if (parseInt(lastMove) != player_turn) return; // Si es del otro jugador vino de la base de datos

    // Procesar el nuevo movimiento
    console.log("New movement detected from file");

    const game_id = meta.split(",")[0];
    const [player, from, to] = lastMove ? lastMove.split(",") : [null, null, null];
    const res = await supabase.from("movements").insert({ game_id, player, from, to });

    if (res.error) {
      console.error(res.error);
      return;
    }

    movesCount++;

    ignoreDatabaseChange = true;
    ignoreFileChange = true;
    console.log("Database updated. Moves: " + movesCount);
  });
}


async function watchDB(game_id) {
  console.log("Watching database...");

  supabase
    .channel("movements")
    .on(
      "postgres_changes",
      { event: "INSERT", schema: "public", table: "movements", filter: `game_id=eq.${game_id}` },
      (payload) => {
        if (ignoreDatabaseChange && !ignoreFileChange) return;  // Si estamos ignorando cambios en la BD y no en el archivo, salimos.

        if (ignoreDatabaseChange && ignoreFileChange) {
          ignoreDatabaseChange = false;  // Resetear el flag cuando ambos son true.
          console.log("Movimiento descargado desde la db exitosamente");
          console.log("Waiting for opponent's move...");
          return;
        }

        const newRow = payload.new;
        console.log("New move detected from database:", newRow);

        const fileLine = Adapter.toFileRow(newRow);
        ignoreFileChange = true;
        appendFileSync("data.txt", fileLine + "\n");
        movesCount++;
        console.log("Move added to file:", fileLine);

        ignoreDatabaseChange = true;
        console.log("File updated. Moves: " + movesCount);
      }
    )
    .subscribe();
}


async function main() {
  const instruction = getInstruction();
  if (!instruction || instruction.length <= 2) return;

  console.log("Instruction received:", instruction);

  if (instruction == "register") await register();
  else if (instruction == "login") await login();
  else if (instruction == "create") await create_game();
  else if (instruction == "join") await join_game();
  else if (instruction == "playing") await playing();
}

const mainLoop = setInterval(main, 2000);
