import "reflect-metadata";
import express from "express";
import cors from "cors";
import dotenv from "dotenv";

console.log("=== Starting server ===");

dotenv.config();
console.log("Environment loaded:", {
  PORT: process.env.PORT,
  NODE_ENV: process.env.NODE_ENV,
  DB_HOST: process.env.DB_HOST,
});

const app = express();
const PORT = process.env.PORT || 8000;

console.log("Express app created");

// Middleware
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    credentials: true,
  }),
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

console.log("Middleware configured");

// Health check route for test
app.get("/health", (req, res) => {
  console.log("Health check requested");
  res.json({
    status: "OK",
    message: "Server is running",
    timestamp: new Date().toISOString(),
  });
});

// API routes
app.get("/api", (req, res) => {
  res.json({
    message: "Todo App with AWS API",
    version: "1.0.0",
  });
});

app.use((req, res) => {
  res.status(404).json({ message: "Route not found" });
});

console.log("Routes configured");

process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
});

process.on("uncaughtException", (error) => {
  console.error("Uncaught Exception:", error);
  process.exit(1);
});

console.log(`Starting server on port ${PORT}...`);

try {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
  });
} catch (error) {
  console.error("Failed to start server:", error);
  process.exit(1);
}

console.log("Server startup initiated");
