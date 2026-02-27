import { Variables } from "~/core/classes/user/variables";

export class Sessions {
    public static getSessionId() {
        let sessionId = Variables.get("User.SessionId");

        if (!sessionId) {
            sessionId = this.generateGUID();
            Variables.set("User.SessionId", sessionId);
        }

        return sessionId;
    }

    public static generateGUID(): string {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAll(/[xy]/g, (c: any) => {
            const randomBuffer = new Uint8Array(1);
            globalThis.crypto.getRandomValues(randomBuffer);
            const r = randomBuffer[0] & 0xf; // get a value between 0 and 15
            const v = c === 'x' ? r : (r & 0x3) | 0x8;
            return v.toString(16);
        });
    }

}