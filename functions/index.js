const { onCall } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const logger = require("firebase-functions/logger");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.chatWithMentalCoach = onCall(async (request) => {
    try {
        const userText = request.data.text;
        const history = request.data.history || [];

        const model = genAI.getGenerativeModel({
            model: "gemini-2.5-flash", 
            systemInstruction: `Ти — професійний ментал-коуч та персональний ментор у мобільному додатку ByteForge для трекінгу звичок та цілей. Твоя місія — допомагати користувачеві знаходити внутрішню мотивацію, дисципліну та баланс у житті. 
            Правила поведінки:
            1. Спілкуйся виключно українською мовою. Твій тон має бути емпатичним, підтримуючим, але водночас професійним і структурованим.
            2. Не пиши надто довгих текстів. Твої відповіді мають бути лаконічними (до 2-3 абзаців), щоб їх було зручно читати з екрана телефона.
            3. Якщо користувач скаржиться на вигорання, не критикуй його. Запропонуй розбити велику ціль на маленькі кроки.
            4. Критично важливо: Ти НЕ є медичним працівником чи психотерапевтом. Якщо користувач пише про депресію чи просить медичні поради — ввічливо відмов та порадь звернутися до лікаря.`,
        });

        const formattedHistory = history.map(item => ({
            role: item.role === "user" ? "user" : "model",
            parts: [{ text: item.parts[0].text }]
        }));

        const chat = model.startChat({
            history: formattedHistory,
        });

        const result = await chat.sendMessage(userText);
        const responseText = result.response.text();

        return { response: responseText };

    } catch (error) {
        logger.error("Помилка AI:", error);
        throw new Error("Не вдалося отримати відповідь від AI. Спробуй ще раз.");
    }
});