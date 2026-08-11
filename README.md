# ZX-ShopRobbery

## ZX-ShopRobbery is a lightweight and immersive FiveM shop robbery script designed to provide a simple and realistic robbery experience.

Players can aim at a shopkeeper to initiate a robbery. After holding the shopkeeper at gunpoint, the NPC raises their hands, walks to the cash register, collects the money and places a money bag on the ground for the player to collect.

## ✨ Features
- 🔫 Aim-to-rob system
- 🙌 Dynamic shopkeeper hands-up animation
- 🚶 Shopkeeper walks to the cash register
- 💰 Cash collection system
- 👜 Money bag pickup system
- 🎲 Randomized robbery rewards
- 👮 Configurable police requirement
- ⏱️ Configurable robbery cooldown
- 🏪 Multiple robbery locations
- 🎬 Configurable animations and scenarios
- ⚙️ Fully configurable
- 🔄 Automatic shop reset
- 🛡️ Server-side robbery validation
- 🧹 Entity cleanup on resource stop

## Framework Support
- ESX
- QB-Core

## Inventory Support
- ox_inventory
- tgiann-inventory
- qs-inventory
- jpr-inventory
- qb-inventory

## Interaction Support
- ox_target
- qb-target
- Text UI

## Notification Support
- ox_lib
- esx_notify
- okokNotify

## ⚙️ Configuration

ZX-ShopRobbery provides a highly configurable setup, allowing you to customize:

- Framework
- Inventory system
- Interaction system
- Notification system
- Target distance and icon
- Aim duration
- Hands-up duration
- Cash collection duration
- Robbery cooldown
- Required police job
- Minimum police online
- Shop locations
- Shopkeeper models
- Animations
- Cash register locations
- Money bag prop
- Minimum and maximum rewards

## 💵 Reward System

Each robbery location can have its own reward configuration with a customizable minimum and maximum amount.

Example:

Rework = {
    reworkItem = "black_money",
    count = {
        min = 5000,
        max = 10000
    }
}

The reward amount is randomly generated between the configured minimum and maximum values.

## 👮 Police Requirement

You can configure how many members of a specific job must be online before a robbery can be started.

required_jobs = {
    job = "police",
    min_job_members_online = 1
}

Supports both ESX and QB-Core job systems.

## ⏱️ Cooldown System

Each shop has its own robbery cooldown, preventing players from repeatedly robbing the same location.

cooldown = 1800000 -- 30 minutes

## 🎮 Robbery Flow
Aim at Shopkeeper
        ↓
Hold Aim
        ↓
Shopkeeper Raises Hands
        ↓
Wait
        ↓
Shopkeeper Walks to Cash Register
        ↓
Cash Collection
        ↓
Money Bag Is Placed
        ↓
Player Collects Money
        ↓
Shop Resets

## 🔐 Security

Important robbery checks are performed server-side before the reward is given, including the player's distance from the robbery location, cooldown status and required police presence.

## 📌 Requirements
- FiveM Server
- One supported framework
- One supported inventory
- One supported interaction system

### ZX-ShopRobbery — Simple, immersive and fully configurable shop robberies for FiveM.

## Preview:
https://youtu.be/z6tG4KRe0hM
