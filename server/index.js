import dotenv from "dotenv";
dotenv.config({ path: ".env" });

import express from "express";
import router from "./routes/pdf.routes.js";

const app = express();
const port = process.env.PORT_NUMBER || 3000;



app.use(express.json());
app.use(express.urlencoded({ extended: true })); 

app.use('/api/pdf', router);

app.listen(port, () => {  
    console.log(`Server is running on port ${port}`);
});
