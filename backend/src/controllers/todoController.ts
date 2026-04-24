import { Request, Response } from "express";
import { validationResult } from "express-validator";
import { todoService } from "../services/todoService";
import { aiService } from "../services/aiService";

export class TodoController {
  async getTodos(req: Request, res: Response) {
    // fetch all todo's for current user
    try {
      if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
      }

      const todos = await todoService.getTodosByUserId(req.userId);
      return res.status(200).json({ todos });
    } catch (error) {
      console.error("Get todos error:", error);
      return res.status(500).json({ message: "Server error" });
    }
  }

  async createTodo(req: Request, res: Response) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
      }

      const { title, description } = req.body;
      const todo = await todoService.createTodo(req.userId, title, description);

      return res.status(201).json({ todo });
    } catch (error) {
      console.error("Create todo error:", error);
      return res.status(500).json({ message: "Server error" });
    }
  }

  async updateTodo(req: Request, res: Response) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
      }

      const { id } = req.params;
      const updates = req.body;

      if (typeof id !== "string") {
        return res.status(400).json({ message: "Invalid todo ID" });
      }

      const todo = await todoService.updateTodo(id, req.userId, updates);
      return res.status(200).json({ todo });
    } catch (error: any) {
      if (error.message === "Todo not found") {
        return res.status(404).json({ message: error.message });
      }
      console.error("Update todo error:", error);
      return res.status(500).json({ message: "Server error" });
    }
  }

  async deleteTodo(req: Request, res: Response) {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
      }

      const { id } = req.params;

      if (typeof id !== "string") {
        return res.status(400).json({ message: "Invalid todo ID" });
      }
      const result = await todoService.deleteTodo(id, req.userId);

      return res.status(200).json(result);
    } catch (error: any) {
      if (error.message === "Todo not found") {
        return res.status(404).json({ message: error.message });
      }
      console.error("Delete todo error:", error);
      return res.status(500).json({ message: "Server error" });
    }
  }

  async getAIsuggestion(req: Request, res: Response) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.userId) {
        return res.status(401).json({ message: "Unauthorized" });
      }

      const { context } = req.body;

      if (!context || typeof context !== "string") {
        return res.status(400).json({ message: "Context is required" });
      }

      if (context.length > 200) {
        return res
          .status(400)
          .json({ message: "Context too long (max 200 characters)" });
      }

      const suggestions = await aiService.generateTodoSuggestions(context);

      return res.status(200).json({
        suggestions,
        context: context,
      });
    } catch (error: any) {
      console.error("suggestions error:", error);

      if (error.name === "AccessDeniedException") {
        return res.status(403).json({
          message:
            "AI service not available. Please contact admin @ amannov21@gmail.com.",
        });
      }
      return res.status(500).json({
        message: "Failed to generate suggestions. Please try again.",
      });
    }
  }
}

export const todoController = new TodoController();
