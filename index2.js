import fs from "node:fs";
import { createClient } from "@supabase/supabase-js";

const URL = "https://zeycferumtubqlaqjsax.supabase.co";
const API_KEY = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpleWNmZXJ1bXR1YnFsYXFqc2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQzODc0MDMsImV4cCI6MjAzOTk2MzQwM30.yre44KeowpW7fHu-kJfGlYnEVlPKZ9sZgUooZucl7WU`;

let ignoreDatabaseChange = false;
let isMyTurn = false;
let waitingForMove = false;

class Parser {
  static async toFileRow(row) {
    return `${row.player},${row.from},${row.to}`;
  }

  static async toDbRow(row) {
    const [player, from, to] = row.split(",");
    return { player, from, to };
  }
}

class SupabaseService {
  constructor() {
    this.client = createClient(URL, API_KEY);
    this.db = this.client.from("movements");
    this.channel = null;
  }

  async subscribe() {
    this.channel = this.client
      .channel("movements")
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public" },
        this.handleChanges.bind(this)
      )
      .subscribe();
  }

  async handleChanges(payload) {
    if (ignoreDatabaseChange) return;

    const newRow = payload.new;
    console.log("Nuevo movimiento detectado en la base de datos:", newRow);
    const fileLine = await Parser.toFileRow(newRow);
    await dataFile.append(fileLine);
    console.log("Movimiento agregado al archivo:", fileLine);
    isMyTurn = true;
    waitingForMove = false;
    const res = await this.channel?.unsubscribe();
    console.log(res)
  }

  async insertData(newRow) {
    const { error } = await this.db.insert(newRow);
    if (error) {
      console.error("Error insertando en la base de datos:", error);
    } else {
      console.log("Movimiento insertado en la base de datos.");
    }
  }

  async getLastMovement() {
    const { data, error } = await this.db
      .select("*")
      .order("id", { ascending: false })
      .limit(1);
    if (error) {
      console.error("Error obteniendo el último movimiento:", error);
      return null;
    }
    return data.length > 0 ? data[0] : null;
  }

  async clearDatabase() {
    const { error } = await this.db.delete().neq("from", "");
    if (error) throw new Error(error.message);
  }
}

class DataFile {
  constructor(fileName) {
    this.fileName = fileName;
    this.lines = this.getLineCount();
  }

  async read() {
    const data = await fs.promises.readFile(this.fileName, "utf-8");
    const lines = data.split("\n")
    return lines.slice(0, this.lines);
  }

  async clear() {
    await fs.promises.writeFile(this.fileName, "", "utf-8");
    this.lines = 0;
  }

  async readLastLine() {
    const data = await fs.promises.readFile(this.fileName, "utf-8");
    const lines = data.split("\n").filter(Boolean);
    return lines.length > 0 ? lines[lines.length - 1] : null;
  }

  async append(line) {
    const lastChar = fs.readFileSync(this.fileName, "utf-8").slice(-1);
    if (lastChar !== "\n") line = "\n" + line;
    await fs.promises.appendFile(this.fileName, line + "\n", "utf-8");
    this.lines++;
  }

  getLineCount() {
    const data = fs.readFileSync(this.fileName, "utf-8");
    const lines = data.split("\n").filter(Boolean);
    return lines.length;
  }

  async processFileChanges(supabaseService) {
    const newLines = await this.read();
    for (const line of newLines) {
      const dbRow = await Parser.toDbRow(line);
      await supabaseService.insertData(dbRow);
      isMyTurn = false;
    }
    // this.lines += newLines.length;
  }
}

// Instancias de las clases
const supabaseService = new SupabaseService();
const dataFile = new DataFile("data.txt");

async function syncFileAndDatabase() {
  const dbMovements = (await supabaseService.db.select("*")).data;
  const dbMovementsCount = dbMovements.length;
  const fileMovements = await dataFile.read();
  const fileMovementsCount = fileMovements.length;

  console.log(dbMovementsCount, fileMovementsCount);

  if (dbMovementsCount === fileMovementsCount) return;

  if (dbMovementsCount > fileMovementsCount) {
    console.log("La base de datos tiene más movimientos que el archivo. Descargando...");
    await dataFile.clear();
    for (const movement of dbMovements) {
      const fileLine = await Parser.toFileRow(movement);
      await dataFile.append(fileLine);
    }
  } else {
    console.log("El archivo tiene más movimientos que la base de datos. Subiendo...");
    await supabaseService.clearDatabase();
    await dataFile.processFileChanges(supabaseService);
  }
}

async function watchFileChanges() {
  try {
    const lineCount = dataFile.getLineCount();
    console.log(lineCount, dataFile.lines);
    if (lineCount > dataFile.lines) {
      const lastLine = await dataFile.readLastLine();

      // Insertamos solo si no se ha procesado antes
      if (lastLine) {
        await supabaseService.insertData(await Parser.toDbRow(lastLine));
        dataFile.lines++;
        isMyTurn = false;
      }
    }
  } catch (error) {
    console.error("Error procesando cambios en el archivo:", error);
  }
}

async function watchDBChanges() {
  ignoreDatabaseChange = false;
  waitingForMove = true;
  supabaseService.subscribe();
}

async function main() {
  console.log("Sincronizando archivo y base de datos...");
  await syncFileAndDatabase();
  console.log("Sincronización completada.");

  const lastLine = await dataFile.readLastLine();
  isMyTurn = !lastLine || lastLine[0] === "0";

  setInterval(async () => {
    try {
      if (isMyTurn) {
        console.log("Esperando cambios en el archivo...");
        await watchFileChanges();
      } else {
        console.log("Esperando cambios en la base de datos...");
        if (!waitingForMove) await watchDBChanges();
      }
    } catch (error) {
      console.error("Error en el intervalo principal:", error);
    }
  }, 2000);
}

main();
