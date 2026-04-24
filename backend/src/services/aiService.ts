import {
  BedrockRuntimeClient,
  InvokeModelCommand,
} from "@aws-sdk/client-bedrock-runtime";

export class AIService {
  private client: BedrockRuntimeClient;
  private modelId = "anthropic.claude-3-haiku-20240307-v1:0:48k";

  constructor() {
    // Initialize Bedrock client in us-east-1 >> Bedrock only exist here :)
    this.client = new BedrockRuntimeClient({
      region: "us-east-1",
    });
  }

  async generateTodoSuggestions(context: string): Promise<string[]> {
    try {
      const prompt = `Generate 5 actionable todo items for: "${context}"

Requirements:
- Make them specific and actionable
- Keep each item concise (under 50 characters)
- Focus on practical tasks
- Return ONLY a JSON array of strings, nothing else

Example format: ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5"]`;

      const requestBody = {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 300,
        temperature: 0.7,
        messages: [
          {
            role: "user",
            content: prompt,
          },
        ],
      };

      const command = new InvokeModelCommand({
        modelId: this.modelId,
        contentType: "application/json",
        accept: "application/json",
        body: JSON.stringify(requestBody),
      });

      const response = await this.client.send(command);

      const responseBody = JSON.parse(new TextDecoder().decode(response.body));

      const generatedText = responseBody.content[0].text;

      const suggestions = JSON.parse(generatedText);

      if (!Array.isArray(suggestions)) {
        throw new Error("AI response was not an array");
      }

      return suggestions.slice(0, 5);
    } catch (error) {
      console.error("AI Service Error:", error);
      throw new Error("Failed to generate AI suggestions");
    }
  }
}

export const aiService = new AIService();
