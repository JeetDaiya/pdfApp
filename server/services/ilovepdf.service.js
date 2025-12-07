import { getAuthToken } from "../utils/ilovepdfAuth.js";
import fs from "fs";
import path from "path";
import axios from "axios";
import FormData from "form-data";

const BASE_URL = "https://api.ilovepdf.com/v1";

export async function compressPDFService(filePath, originalName) {
  const token = getAuthToken();

  // 1️⃣ Start task 
  console.log("Starting task...");
  const start = await axios.get(
    `${BASE_URL}/start/compress`,
    { 
      headers: { Authorization: `Bearer ${token}` } 
    }
  );

  const { task, server } = start.data;
  console.log(`Task started: ${task} on server ${server}`);

  // 2️⃣ Upload 
  const form = new FormData();
  form.append("task", task);
  

  form.append("file", fs.createReadStream(filePath), originalName);

 

  const upload = await axios.post(
    `https://${server}/v1/upload`,
    form,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        ...form.getHeaders() // Merges Content-Type and Boundary
      },
      maxContentLength: Infinity,
      maxBodyLength: Infinity
    }
  );

  console.log("Upload successful:", upload.data.server_filename);

  // 3️⃣ Process
  console.log("Processing...");
  await axios.post(
    `https://${server}/v1/process`,
    { 
      task: task,
      tool: "compress", // Explicitly state the tool
      files: [
        {
          server_filename: upload.data.server_filename,
          filename:originalName
        }
      ]
    },
    {
      headers: { Authorization: `Bearer ${token}` }
    }
  );

  // 4️⃣ Download
  console.log("Downloading...");
  const fileStream = await axios.get(
    `https://${server}/v1/download/${task}`,
    { 
      responseType: "stream",
      headers: { Authorization: `Bearer ${token}` }
    }
  );

  const outputPath = path.join("processed", `compressed_${originalName}`);
  
  // Ensure directory exists
  if (!fs.existsSync("processed")) {
    fs.mkdirSync("processed");
  }
  const writer = fs.createWriteStream(outputPath);
  fileStream.data.pipe(writer);
  await new Promise((resolve, reject) => {
    writer.on("finish", resolve);
    writer.on("error", reject);
  });

  console.log("Finished:", outputPath);

  return outputPath;
}
