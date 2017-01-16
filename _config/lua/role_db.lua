local role_db = {
  types = { 'I', 'S', 'S', 'S', 'S', 'I', 'S', 'F', 'B', },
  fields = { 'id', 'name', 'icon', 'quality', 'attr', 'order', 'upId', 'heigh', 'isHero', },
  values = {
    { '1', '雷古曼', 'icon/head16', 'Text/q1', 'Text/attr_huo_1', '16', '1', '12.3', 'True', },
    { '2', '雷古曼-轻装', 'icon/head17', 'Text/q2', 'Text/attr_huo_1', '17', '2', '43.2', 'False', },
    { '3', '雷古曼-重装', 'icon/head18', 'Text/q3', 'Text/attr_huo_1', '18', '3', '23.234', 'True', },
    { '4', '雷古曼-铠甲兽龙', 'icon/rob6', 'Text/q3', 'Text/attr_huo_1', '', '511', '65.3', '', },
  },
}
return role_db
