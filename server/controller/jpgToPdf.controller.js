import { jpgToPdfService } from "../services/jpgToPdf.service.js";
import path from "path";
import fs from "fs";

export async function jpgToPdf(req, res) {
  const filesArray = req.files;
  try {
      const outputPath = await jpgToPdfService(filesArray);
      const absolutePath = path.resolve(outputPath);
      res.sendFile(absolutePath, function (err) {
        // Clean up uploaded files
        filesArray.forEach((file) => {
          fs.unlink(file.path, (err) => {});
        });
  
        if (outputPath) {
          fs.unlink(outputPath, () => {});
        }
  
        if (err) {
          console.log("Download interrupted/failed:", err.message);
          if (!res.headersSent) {
            res.status(500).send("Transfer Failed");
          }
        } else {
          console.log("File sent successfully.");
        }
      });
    } catch (error) {
      console.log("==================================");
      console.log(error);
      console.log("==================================");
      res.status(500).json({ error: "Failed to convert JPG to PDF" });
    }
  }