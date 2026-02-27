import { Utils } from "~/core/utils/random";

export class Colors {
    public static readonly defaultColors: any[] = [
        "#02d8e3",
        "#349ceb",
        "#B2CC34",
        "#00858c",
        "#004d87",
        "#829c03"
    ];

    public static getRandomColors(count: number = 1): any {
        let colors: any[] = [];
        let letters = '0123456789ABCDEF'.split('');

        for (let c = 0; c < count && c < Colors.defaultColors.length; c++) {
            colors.push(Colors.defaultColors[c]);
        }

        while (colors.length < count) {
            let color: any = '#';

            for (let i = 0; i < 6; i++) {
                color += letters[Utils.random(0, 15)];
            }

            if (!colors.includes(color)) {
                colors.push(color);
            }
        }

        return colors;
    }
}