import { getAuthToken } from "../utils/ilovepdfAuth.js";
import fs from "fs";
import path from "path";
import axios from "axios";
import FormData from "form-data";

const BASE_URL = "https://api.ilovepdf.com/v1";

export async function jpgToPdfService(filesArray){
    const token = getAuthToken();
    
    const originalName = filesArray[0].originalname.replace(path.extname(filesArray[0].originalname), '.pdf');  
    console.log("Starting task...");
    const start = await axios.get(
        `${BASE_URL}/start/imagepdf`,
        { 
        headers: { Authorization: `Bearer ${token}` } 
        }
    );
    
    const { task, server } = start.data;
    console.log(`Task started: ${task} on server ${server}`);
    const uploadedFiles = [];
    for(const file of filesArray){
        console.log(`File to convert: ${file.originalname}`);
        const form = new FormData();
        form.append("task", task);
        form.append("file", fs.createReadStream(file.path), file.originalname);
        console.log(`Uploading file ${file.originalname}...`);
        
        try {
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

            uploadedFiles.push({
                server_filename: upload.data.server_filename,
                filename: file.originalname
            });

            
        } catch (error) {

            console.log(`Error uploading file ${file.originalname}:`, error);
            throw error;

        }
    }

    console.log("Processing...");
    await axios.post(
        `https://${server}/v1/process`,
        { 
        task: task,
        tool: "imagepdf", // Explicitly state the tool
        files: uploadedFiles,
        merge_after: true
        },
        {
        headers: { Authorization: `Bearer ${token}` }
        }
    );

    console.log("Downloading result...");
    const downloadResponse = await axios.get(
        `https://${server}/v1/download/${task}`,
        {
        headers: { Authorization: `Bearer ${token}` },
        responseType: "stream"
        }
    );

    const outputFilePath = path.join("processed", `converted_${originalName}`);
     if (!fs.existsSync("processed")) {
        fs.mkdirSync("processed");
      }
    const writer = fs.createWriteStream(outputFilePath);

    downloadResponse.data.pipe(writer);

    await new Promise((resolve, reject) => {
    writer.on("finish", resolve);
    writer.on("error", reject);
  });

  console.log("Finished:", outputFilePath);

  return outputFilePath;
}

    