import multer from 'multer';
import express from 'express';
import {compressPDF} from '../controller/ilovepdf.controller.js';

const router = express.Router();
const upload = multer({ dest: 'uploads/' });

router.post('/compress', upload.single('file'), compressPDF);

export default router;