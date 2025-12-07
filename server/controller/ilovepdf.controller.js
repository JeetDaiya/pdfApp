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

            if(err && !res.headersSent){
                res.status(500).send("Transfer Failed");
            }
            
        })


    } catch (error) {
        console.log('==================================');
        console.log(error);
        console.log('==================================');
        res.status(500).json({ error: 'Failed to compress PDF' });
    }
}