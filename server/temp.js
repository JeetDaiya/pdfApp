// 👇 UPDATE THIS PATH to point to your actual file
import { compressPDFService } from "./services/ilovepdf.service.js";
import path from "path";

(async () => {
  console.log("🚀 Starting Compression Test...");

  const inputPath = "./uploads/sample.pdf"; // Make sure this file exists!
  
  try {
    const result = await compressPDFService(inputPath, "sample.pdf");
    console.log("✅ Success! File saved to:", result);
  } catch (error) {
    console.error("\n❌ TEST FAILED");
    
    if (error.response) {
      // 🕵️ THIS IS THE SECRET SAUCE
      // This forces Node to print the hidden [Object] error details
      console.error("------------------------------------------------");
      console.error("API Error Details:");
      console.error(JSON.stringify(error.response.data, null, 2));
      console.error("------------------------------------------------");
    } else {
      console.error("Error Message:", error.message);
    }
  }
})();