local ADDON, ns = ...



for _, def in ipairs(ns.ItemList) do
  if not def.rank then ns.RefreshItemMetadata(def) end
end
ns.Ranks.RegisterAll()
