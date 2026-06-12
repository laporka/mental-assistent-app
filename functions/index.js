const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const API_KEY = process.env.GEMINI_API_KEY;

exports.chatWithMentalCoach = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Тільки авторизовані користувачі можуть писати коучу.");
    }

    const userMessage = request.data.text; 
    const chatHistory = request.data.history || [];

    try {
        const genAI = new GoogleGenerativeAI(API_KEY);
        const model = genAI.getGenerativeModel({
            model: "gemini-1.5-flash",
            systemInstruction: `Ти — професійний ментал-коуч та персональний ментор у мобільному додатку ByteForge для трекінгу звичок та цілей. Твоя місія — допомагати користувачеві знаходити внутрішню мотивацію, дисципліну та баланс у житті. 
            Правила поведінки:
            1. Спілкуйся виключно українською мовою. Твій тон має бути емпатичним, підтримуючим, але водночас професійним і структурованим.
            2. Не пиши надто довгих текстів. Твої відповіді мають бути лаконічними (до 2-3 абзаців), щоб їх було зручно читати з екрана телефона.
            3. Якщо користувач скаржиться на вигорання, не критикуй його. Запропонуй розбити велику ціль на маленькі кроки.
            4. Критично важливо: Ти НЕ є медичним працівником чи психотерапевтом. Якщо користувач пише про депресію чи просить медичні поради — ввічливо відмов та порадь звернутися до лікаря.`,
        });

        const chat = model.startChat({
            history: chatHistory,
        });

        const result = await chat.sendMessage(userMessage);
        const responseText = result.response.text();

        return { 
            response: responseText 
        };

    } catch (error) {
        console.error("Помилка генерації AI:", error);
        throw new HttpsError("internal", "Не вдалося отримати відповідь від AI.");
    }
});