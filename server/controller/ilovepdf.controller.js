import { compressPDFService } from '../services/ilovepdf.service.js';
import path from 'path';
import fs from 'fs';
export async function compressPDF (req,res){
    const originalName = req.file.originalname;
    const filepath = req.file.path;

    try {
        const outputPath = await compressPDFService(filepath, originalName);
        const absolutePath = path.resolve(outputPath);
        res.sendFile(absolutePath, function (err) {
            fs.unlink(filepath, (err)=>{});
            if(outputPath){
                    fs.unlink(outputPath,()=>{})
            }

            if (err) {
                console.log("Download interrupted/failed:", err.message);
                if (!res.headersSent) {
                    res.status(500).send("Transfer Failed");
                }
            } else {
                console.log("File sent successfully.");
            }
            
        })


    } catch (error) {
        console.log('==================================');
        console.log(error);
        console.log('==================================');
        res.status(500).json({ error: 'Failed to compress PDF' });
    }
}