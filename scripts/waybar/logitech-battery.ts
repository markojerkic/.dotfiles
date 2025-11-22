#!/usr/bin/env bun
import { $ } from "bun";
import { homedir } from "os";

const arg = process.argv[2] as "mouse" | "keyboard";
if (arg === undefined) {
    console.error("Usage: logitech-battery.ts mouse|keyboard");
    process.exit(1);
}

const xdgConfigHome = process.env.XDG_CONFIG_HOME || `${homedir()}/.config`;
const configPath = `${xdgConfigHome}/.solaar-waybar-cache-${arg}.json`;

type Device = {
    battery: string;
    status: "DISCHARGING" | "RECHARGING";
};

let mouse: Device | undefined;
let keyboard: Device | undefined;

for (const deviceId of [1, 2]) {
    const result = await $`solaar show ${deviceId}`.quiet();
    const solaarOutput = result.stdout.toString();

    const deviceKind = solaarOutput.match(/Kind\s*:\s*(\w+)/)?.[1];
    if (deviceKind === "mouse") {
        mouse = {
            battery: "0",
            status: "DISCHARGING",
        };
    } else if (deviceKind === "keyboard") {
        keyboard = {
            battery: "0",
            status: "DISCHARGING",
        };
    }

    const device = deviceKind === "mouse" ? mouse : keyboard;

    const battery = solaarOutput.match(/Battery\s*:\s*(\w+)%/)?.[1];
    if (battery !== undefined) {
        device!.battery = battery;
    }

    const status = solaarOutput.match(/BatteryStatus.(\w+)/)?.[1];
    if (status !== undefined) {
        device!.status = status as "DISCHARGING" | "RECHARGING";
    }
}

const mouseIcon = "󰍽";
const keyboardIcon = "󰌌";
let className = "normal";

function isBatteryCritical(device: Device | undefined) {
    if (device === undefined) {
        return false;
    }

    return (
        device.status === "DISCHARGING" &&
        Number.parseFloat(device.battery) <= 30
    );
}

function isBatteryWarning(device: Device | undefined) {
    if (device === undefined) {
        return false;
    }

    return (
        device.status === "DISCHARGING" &&
        Number.parseFloat(device.battery) <= 50
    );
}

if (mouse === undefined && keyboard === undefined) {
    await Bun.write(
        Bun.file(configPath),
        JSON.stringify({ text: "", class: "hidden" }),
    );
    console.log(await Bun.file(configPath).text());
    process.exit(0);
}

const device = arg === "mouse" ? mouse : keyboard;

if (isBatteryCritical(device)) {
    className = "critical";
} else if (isBatteryWarning(device)) {
    className = "warning";
}

const icon = arg === "mouse" ? mouseIcon : keyboardIcon;
const result = {
    text: `${icon} ${device!.battery}%`,
    class: className,
    tooltip:
        device?.status === "DISCHARGING" ? "󰁾 Discharging" : "󰂅 Recharging",
};

await Bun.write(Bun.file(configPath), JSON.stringify(result));

console.log(JSON.stringify(result));
