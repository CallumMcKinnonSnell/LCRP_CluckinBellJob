SET @job_name = 'cluckinbell';
SET @society_name = 'society_cluckinbell';
SET @job_Name_Caps = 'Cluckin Bell';



INSERT INTO `addon_account` (name, label, shared) VALUES
  (@society_name, @job_Name_Caps, 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
  (@society_name, @job_Name_Caps, 1),
  ('society_cluckin_fridge', 'cluckin (frigo)', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
    (@society_name, @job_Name_Caps, 1)
;

INSERT INTO `jobs` (name, label, whitelisted) VALUES
  (@job_name, @job_Name_Caps, 1)
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  (@job_name, 0, 'recruit', 'Recruit Cluck', 1, '{}', '{}'),
  (@job_name, 1, 'worker', 'Teen Cluck', 1, '{}', '{}'),
  (@job_name, 2, 'viceboss', 'Adult Cluck', 1, '{}', '{}'),
  (@job_name, 3, 'boss', 'Boss Cluck', 1, '{}', '{}')
;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`, `degrademodifier`, `unique`) VALUES
('cluckin_tendies', 'Cluckin Tendies', 1, 0, 1, 0, 0),
('cluckin_drink', 'Cluckin Drink', 1, 0, 1, 0, 0),
('cluckin_fries', 'Cluckin Fries', 1, 0, 1, 0, 0),
('cluckin_meal', 'Cluckin Meal', 5, 0, 1, 0, 0);