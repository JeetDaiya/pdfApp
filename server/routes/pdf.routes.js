import multer from 'multer';
import express from 'express';
import {compressPDF} from '../controller/compresspdf.controller.js';
import { mergePDF } from '../controller/mergepdf.controller.js';
import { jpgToPdf } from '../controller/jpgToPdf.controller.js';


const router = express.Router();
const upload = multer({ dest: 'uploads/' });

router.post('/compress', upload.single('file'), compressPDF);
router.post('/merge', upload.array('files', 10), mergePDF);
router.post('/jpg-to-pdf', upload.array('files', 20), jpgToPdf);

export default router;