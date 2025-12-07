import jwt from "jsonwebtoken";
import dotenv from "dotenv";
dotenv.config();

export function getAuthToken() {
  const publicKey = process.env.ILOVEPDF_PUBLIC_KEY ;
  const secretKey = process.env.ILOVEPDF_SECRET_KEY ;

  // Current time in seconds
  const now = Math.floor(Date.now() / 1000);

  // Payload structure required by iLovePDF
  const payload = {
    iss: "api.ilovepdf.com", // Issuer
    aud: "https://api.ilovepdf.com/v1", // Audience
    iat: now,                // Issued at
    nbf: now,                // Not before
    exp: now + 7200,         // Expires in 2 hours (2 * 60 * 60)
    jti: publicKey           // JTI must be your Public Key
  };

  // Sign the token using your Secret Key
  const token = jwt.sign(payload, secretKey, { algorithm: "HS256" });

  return token;
}