const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const logger = require("firebase-functions/logger");

exports.chatWithMentalCoach = onCall(async (request) => {
    try {
        const userText = request.data.text;
        const history = request.data.history || [];

        const customApiKey = request.data.apiKey; 

        if (customApiKey && customApiKey.trim() !== '') {
            const masked = customApiKey.substring(0, 4) + '***' + customApiKey.substring(customApiKey.length - 4);
            logger.info("✅ Запит прийшов з КАСТОМНИМ ключем користувача:", masked);
        } else {
            logger.info("⚠️ Кастомного ключа немає. Використовуємо СТАНДАРТНИЙ ключ сервера.");
        }

        let validHistory = [];
        let expectedRole = "user";

        for (const item of history) {
            if (!item.parts || !item.parts[0] || !item.parts[0].text) continue;
            
            const currentRole = item.role === "user" ? "user" : "model";
            
            if (currentRole === expectedRole) {
                validHistory.push({
                    role: currentRole,
                    parts: [{ text: item.parts[0].text }]
                });
                expectedRole = expectedRole === "user" ? "model" : "user";
            } else if (validHistory.length > 0) {
                validHistory[validHistory.length - 1].parts[0].text += "\n" + item.parts[0].text;
            }
        }

        if (validHistory.length > 0 && validHistory[validHistory.length - 1].role === "user") {
            validHistory.pop();
        }

        const defaultApiKey = process.env.GEMINI_API_KEY;
        const apiKeyToUse = (customApiKey && customApiKey.trim() !== '') ? customApiKey : defaultApiKey;

        if (!apiKeyToUse) {
            throw new Error("Ключ API не знайдено (ні користувацького, ні стандартного)!");
        }

        const genAI = new GoogleGenerativeAI(apiKeyToUse);
        const model = genAI.getGenerativeModel({
            model: "gemini-2.5-flash", 
            systemInstruction: `Ти — професійний ментал-коуч та персональний ментор у мобільному додатку ByteForge для трекінгу звичок та цілей. Твоя місія — допомагати користувачеві знаходити внутрішню мотивацію, дисципліну та баланс у житті. 
            Правила поведінки:
            1. Спілкуйся виключно українською мовою. Твій тон має бути емпатичним, підтримуючим, але водночас професійним і структурованим.
            2. Не пиши надто довгих текстів. Твої відповіді мають бути лаконічними (до 2-3 абзаців), щоб їх було зручно читати з екрана телефона.
            3. Якщо користувач скаржиться на вигорання, не критикуй його. Запропонуй розбити велику ціль на маленькі кроки.
            4. Критично важливо: Ти НЕ є медичним працівником чи психотерапевтом. Якщо користувач пише про депресію чи просить медичні поради — ввічливо відмов та порадь звернутися до лікаря.`,
        });

        const chat = model.startChat({ history: validHistory });
        const result = await chat.sendMessage(userText);
        
        return { response: result.response.text() };

    } catch (error) {
        logger.error("Детальна помилка AI:", error);
        throw new HttpsError("internal", "Збій генерації: " + error.message);
    }
});