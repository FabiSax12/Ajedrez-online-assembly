import fs from "node:fs"
import { createClient } from "@supabase/supabase-js"

const URL = "https://zeycferumtubqlaqjsax.supabase.co"
const API_KEY = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpleWNmZXJ1bXR1YnFsYXFqc2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQzODc0MDMsImV4cCI6MjAzOTk2MzQwM30.yre44KeowpW7fHu-kJfGlYnEVlPKZ9sZgUooZucl7WU`

class SupabaseService {
  endpoint = "https://zeycferumtubqlaqjsax.supabase.co/storage/v1/object/games"

  constructor() {
    this.supabase = createClient(URL, API_KEY)
    this.storage = this.supabase.storage.from("games")
    this.database = this.supabase;
  }

  async createDataFile(fileName, content) {
    console.log("Creating data file...")
    try {
      const { data, error } = await this.storage.list()

      if (error) throw new Error(error.message)

      if (data.some(file => file.name === fileName)) {
        console.log("El archivo ya existe, renombrando archivo anterior...")
        const gameId = (await this.downloadFile("data.txt")).split("\n")[0]
        await this.storage.move(fileName, `${gameId}.txt`)
      }

      const res = await this.uploadFile(fileName, content + "\n")
      if (res.error) throw new Error(res.error.message)
      return true
    } catch (error) {
      console.error("Error al crear el archivo de datos:", error.message)
      return false
    }
  }

  async uploadFile(fileName, content) {
    const res = await this.storage.upload(fileName, content, {
      upsert: true,
      contentType: "text/plain",
    })

    if (res.error) throw new Error(res.error.message)
    return res.data
  }

  async downloadFile(fileName) {
    const res = await this.storage.download(fileName)
    console.log(res)

    if (res.error) {
      if (res.error.name === "StorageFileNotFoundError") {
        console.log("El archivo remoto no existe, subiendo el archivo local...")
        const localContent = fs.readFileSync(`./${fileName}`, "utf-8")
        await this.uploadFile(fileName, localContent)
        return localContent
      }
      throw new Error(res.error.message)
    }

    return await res.data.text()
  }
}

class DataFile {
  constructor(fileName, content = "") {
    this.fileName = fileName
    this.content = content
  }

  get lines() {
    return this.content.split("\n").length
  }

  set setContent(data) {
    this.content = data
  }

  get getContent() {
    return this.content
  }
}

class LocalData extends DataFile {
  constructor(fileName) {
    const content = fs.existsSync(`./${fileName}`)
      ? fs.readFileSync(`./${fileName}`, "utf-8")
      : ""
    super(fileName, content)
  }

  save() {
    fs.writeFileSync(`./${this.fileName}`, this.content)
  }

  refresh() {
    this.content = fs.readFileSync(`./${this.fileName}`, "utf-8")
  }

  write(text) {
    fs.appendFileSync(`./${this.fileName}`, text)
    this.content += text
  }
}

class RemoteData extends DataFile {
  constructor(fileName, supabaseService) {
    super(fileName)
    this.supabaseService = supabaseService
  }

  async refresh() {
    console.log("Refreshing remote data...")
    this.content = await this.supabaseService.downloadFile(this.fileName)
  }

  async save() {
    await this.supabaseService.uploadFile(this.fileName, this.content)
  }
}

// Lógica principal
async function main() {
  const supabaseService = new SupabaseService()
  const localData = new LocalData("data.txt")
  const remoteData = new RemoteData("data.txt", supabaseService)

  // await remoteData.download()

  if (localData.lines <= 1) {
    await supabaseService.createDataFile(localData.fileName, localData.getContent)
    localData.write("\n")
    await remoteData.refresh()
  }
  else {
    await remoteData.refresh()
  }

  if (remoteData.lines > localData.lines) {
    localData.setContent = remoteData.getContent
    localData.save()
    console.log("Datos locales actualizados con datos remotos")

  } else if (remoteData.lines < localData.lines) {
    remoteData.setContent = localData.getContent
    await remoteData.save()
    console.log("Datos remotos actualizados con datos locales")

  } else {
    console.log("No hay cambios en los datos del juego")
  }
}

await main()
