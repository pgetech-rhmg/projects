const LOCAL_KEY = "DASH_AppLocal";
const SESSION_KEY = "DASH_AppSession";

export enum VariableType {
    Session = 1, // Persists variables in a single tab and ONLY during a given session.
    Local = 2 // Persists variables across tabs and after session is terminated.
}

export class Variables {
    public static get(key: any, type: VariableType = VariableType.Session) {
        let storage: any = Variables.getStorage(type);
        let data: any = null;
        let variable: any = null;

        if (storage) {
            data = JSON.parse(storage);

            let ndx = data.variables.findIndex((v: any) => key in v);

            if (ndx > -1) {
                variable = data.variables[ndx][key];
            }
        }

        return variable;
    }

    public static set(key: any, value: any, type: VariableType = VariableType.Session) {
        let storage: any = Variables.getStorage(type);
        let data: any = null;

        let obj: any = {};
        obj[key] = value;

        if (storage) {
            data = JSON.parse(storage);

            let ndx = data.variables.findIndex((v: any) => key in v);

            if (ndx > -1) {
                data.variables[ndx][key] = value;
            } else {
                data.variables.push(obj);
            }

            Variables.setStorage(type, data);
        } else {
            data = {
                variables: [obj]
            };

            Variables.setStorage(type, data);
        }
    }

    public static clear(key: any = "all", type: VariableType = VariableType.Session) {
        if (key === "all") {
            if (type === VariableType.Session) {
                sessionStorage.removeItem(SESSION_KEY);
            } else {
                localStorage.removeItem(LOCAL_KEY);
            }
        } else {
            let storage = Variables.getStorage(type);
            let data: any = null;

            if (storage) {
                data = JSON.parse(storage);

                data.variables = data.variables.filter((v: any) => !(key in v));

                Variables.setStorage(type, data);
            }
        }
    }

    private static getStorage(type: VariableType) {
        if (type === VariableType.Session) {
            return sessionStorage.getItem(SESSION_KEY) ?? null;
        } else {
            return localStorage.getItem(LOCAL_KEY) ?? null;
        }
    }

    private static setStorage(type: VariableType, data: any) {
        if (type === VariableType.Session) {
            sessionStorage.setItem(SESSION_KEY, JSON.stringify(data));
        } else {
            localStorage.setItem(LOCAL_KEY, JSON.stringify(data));
        }
    }
}
