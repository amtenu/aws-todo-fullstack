import request from "supertest";
import { app } from "../app";
import { AppDataSource } from "../config/database";

import { User } from "../entities/User";

beforeAll(async () => {
  if (!AppDataSource.isInitialized) {
    await AppDataSource.initialize();
  }
});

afterAll(async () => {
  if (AppDataSource.isInitialized) {
    await AppDataSource.destroy();
  }
});

beforeEach(async () => {
  const userRepository = AppDataSource.getRepository(User);
  await userRepository.clear();
});

beforeEach(async () => {
  const userRepository = AppDataSource.getRepository(User);
  await userRepository.clear();
});

describe("POST /api/auth/register", () => {
  it("should register a new user with valid data", async () => {
    const response = await request(app).post("/api/auth/register").send({
      email: "test@example.com",
      password: "Password@",
      name: "Aman test",
    });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty("token");
    expect(response.body.user).toHaveProperty("email", "test@example.com");
    expect(response.body.user).toHaveProperty("name", "Aman user");
    expect(response.body.user).not.toHaveProperty("password");
  });

  it("should return 400 if email is invalid", async () => {
    const response = await request(app).post("/api/auth/register").send({
      email: "invalid-email",
      password: "Password@",
    });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty("errors");
  });

  it("should return 400 if password is too short", async () => {
    const response = await request(app).post("/api/auth/register").send({
      email: "test@example.com",
      password: "123",
    });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty("errors");
  });

  it("should return 400 if email already exists", async () => {
    await request(app).post("/api/auth/register").send({
      email: "duplicate@example.com",
      password: "Password@",
    });

    const response = await request(app).post("/api/auth/register").send({
      email: "duplicate@example.com",
      password: "Password@",
    });

    expect(response.status).toBe(400);
    expect(response.body.message).toContain("already exists");
  });

  it("should hash the password before saving", async () => {
    const password = "Password@";

    await request(app).post("/api/auth/register").send({
      email: "test@example.com",
      password: password,
    });

    const userRepository = AppDataSource.getRepository(User);
    const user = await userRepository.findOne({
      where: { email: "test@example.com" },
    });

    expect(user?.password).not.toBe(password);
    expect(user?.password).toMatch(/^\$2[ayb]\$.{56}$/); // bcrypt hash format
  });
});
