import { getAuthToken } from "../utils/ilovepdfAuth.js";
import fs from "fs";
import path from "path";
import axios from "axios";
import FormData from "form-data";
import { log } from "console";

const BASE_URL = "https://api.ilovepdf.com/v1";


export async function mergePDFService(filesArray){
    const token = getAuthToken();

    const originalName = filesArray[0].originalname;

    console.log("Starting task...");
    const start = await axios.get(
        `${BASE_URL}/start/merge`,
        { 
        headers: { Authorization: `Bearer ${token}` } 
        }
    );

    const { task, server } = start.data;
    console.log(`Task started: ${task} on server ${server}`);

    const uploadedFiles = [];


    for(const file of filesArray){
        console.log(`File to merge: ${file.originalname}`);
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
                filename: file.originalname,
                rotate: 0
            });

            
        } catch (error) {

            console.log(`Error uploading file ${file.originalname}:`, error);
            throw error;
            
        }
            

    }
   
    console.log(`Successfully uploaded ${uploadedFiles.length} files.`);


    console.log("Processing...");
    await axios.post(
        `https://${server}/v1/process`,
        { 
        task: task,
        tool: "merge", // Explicitly state the tool
        files: uploadedFiles,
        },
        {
        headers: { Authorization: `Bearer ${token}` }
        }
    );

    console.log("Downloading...");
    const fileStream = await axios.get(
        `https://${server}/v1/download/${task}`,
        { 
        responseType: "stream",
        headers: { Authorization: `Bearer ${token}` }
        }
    );

    const outputPath = path.join("processed", `${originalName}_merged.pdf`);
      
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