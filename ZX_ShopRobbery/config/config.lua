Config = {}

Config.Settings = {
    Framework = {
        type = "esx" -- esx, qb-core
    },
    Interaction = {
        type = "ox_target", -- qb-target, textUi, ox_target
        targetIcon = "fa-solid fa-sack-dollar",
        distance = 3.5
    },
    Inventory = {
        type = "tgiann-inventory" -- ox_inventory, qs-inventory, jpr-inventory, qb-inventory, tgiann-inventory
    },
    Notify = {
        type = "ox_lib", -- esx_notify, okokNotify, ox_lib
        notifyDuration = 5000 -- 5 sec
    }
}

Config.RobberySettings = {
    aim_time_required = 1000, -- 1 sec
    timeToHandsUpToCash = 1000, -- 1 sec
    gettingCashTime = 5000, -- 5 sec
    cooldown = 1800000, -- 30min
    required_jobs = {
        job = "police",
        min_job_members_online = 1
    }
}

Config.Robberys = {
    {
        Ped = {
            coords = vector4(372.7469, 326.9222, 102.5661, 252.8321),
            model = "MP_M_ShopKeep_01",  -- MP_M_ShopKeep_01
            animations = {
                normalScenario = "WORLD_HUMAN_HANG_OUT_STREET", -- Idle Scenario
                animDict = "idle_a", -- Hands Up Animation
                animName = "anim@mp_player_intuppersurrender"
            }
        },
        GettingCash = {
            coords = vector3(372.6760, 328.2440, 103.5661),
            heading = 256.9265,
            animations = {
                animDict = "grab",
                animName = "anim@scripted@heist@ig1_table_grab@gold@male@" 
            }
        },
        PlacingCash = {
            coords = vector3(373.286, 327.480, 103.527),
            prop = "prop_poly_bag_01",
            animations = {
                animDict = "pickup",
                animName = "anim@move_m@trash"                 
            }

        },
        Rework = {
            reworkItem = "black_money",
            count = {
                min = 5000,
                max = 10000
            }
        },
    },
    {
        Ped = {
            coords = vector4(24.4691, -1346.9200, 28.4968, 265.9135),
            model = "MP_M_ShopKeep_01",  -- MP_M_ShopKeep_01
            animations = {
                normalScenario = "WORLD_HUMAN_HANG_OUT_STREET", -- Idle Scenario
                animDict = "idle_a", -- Hands Up Animation
                animName = "anim@mp_player_intuppersurrender"
            }
        },
        GettingCash = {
            coords = vector3(24.5222, -1345.5355, 29.4968),
            heading = 268.5717,
            animations = {
                animDict = "grab",
                animName = "anim@scripted@heist@ig1_table_grab@gold@male@" 
            }
        },
        PlacingCash = {
            coords = vector3(25.112, -1346.073, 29.458),
            prop = "prop_poly_bag_01",
            animations = {
                animDict = "pickup",
                animName = "anim@move_m@trash"                 
            }

        },
        Rework = {
            reworkItem = "black_money",
            count = {
                min = 5000,
                max = 10000
            }
        },
    }
}