Config ={}

Config.Locale = 'en'

Config.DrawDistance = 100
Config.EnableVaultManagement = true
Config.EnableMoneyWash = false
Config.MarkerDistance = 1

--Direction to face when doing animation
Config.FriesHeading     =   90.00
Config.TendiesHeading   =   90.00
Config.DrinkHeading     =   270.00
Config.MealHeading      =   98.00

--Timings for animations
Config.CookFriesTime    = 6000
Config.CookTendiesTime   = 10000
Config.MakeDrinkTime    = 4000
Config.PrepMealTime     = 12000

--Props
Config.MealName			= 'ng_proc_food_bag01a'
Config.DrinkName		= 'prop_food_bs_juice01'
Config.TendiesNames		= {a = 'prop_food_cb_nugets', b = 'prop_food_bs_burg1', c = 'prop_food_bs_burg3'}
Config.FriesName		= 'prop_food_bs_chips'
Config.TrayName			= 'prop_food_bs_tray_01'

--Boss Ped
Config.BossPed          = 's_m_m_linecook'
Config.BossCoords       = {x = -510.18, y = -702.52, z = 32.17}
Config.BossHeading      = 45.10

--Prop Positions

--Animation positions
Config.GetFriesPos          = {x = -520.15, y = -701.4, z = 32.37}
Config.GetTendiesPos        = {x = -519.99, y = -701.4, z = 32.37}
Config.GetDrinkPos          = {x = -515.64, y = -698.99, z = 32.37}
Config.GetMealPos           = {x = -519.81, y = -698.97, z = 32.37}

Config.Vehicle = {
    Code                 = "chickenrun",
    Pos                  = { x = -505.15, y = -668.60, z = 33.00},
    Heading              = 270.00,
}