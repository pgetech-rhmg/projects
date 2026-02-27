import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { lastValueFrom } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class GraphService {
    constructor(private readonly http: HttpClient) { }

    public async getUserPhoto(): Promise<string> {
        let token = localStorage.getItem('msal.idtoken');

        if (token) {
            return new Promise<string>((resolve, reject) => {
                const url = "https://graph.microsoft.com/v1.0/me/photo/$value";
                const headers = new HttpHeaders({
                    Authorization: `Bearer ${token}`
                });

                const stream$ = this.http.get(url, { headers, responseType: "blob" });

                lastValueFrom(stream$)
                    .then((response: Blob) => {
                        if (!response) {
                            resolve(""); // no photo
                            return;
                        }

                        const reader = new FileReader();
                        reader.readAsDataURL(response);

                        reader.onloadend = () => {
                            resolve(reader.result as string);
                        };

                        reader.onerror = () => {
                            reject(new Error('FileReader failed'));
                        };
                    })
                    .catch((error: Error) => {
                        reject(error);
                    });
            });
        } else {
            return "";
        }
    }

    public async getUserGroups(role: any): Promise<any> {
        let token = localStorage.getItem('msal.idtoken');

        if (token) {
            try {
                let url = `https://graph.microsoft.com/v1.0/me/transitiveMemberOf/microsoft.graph.group?$count=true&$orderby=displayName&$filter=startswith(displayName, '${role}')`;
                let headers: HttpHeaders = new HttpHeaders({
                    Authorization: `Bearer ${token}`,
                    ConsistencyLevel: "eventual"
                });
                let stream$ = this.http.get(url, { headers: headers });

                return await lastValueFrom(stream$);
            } catch (error: any) {
                throw error;
            }
        } else {
            return null;
        }
    }
}
