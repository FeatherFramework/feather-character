-- Actual locale adapter, English file and catalog; mocked Core locale boundary.
local translations,lang,fail={},'en_us',false
exports={['feather-core']={
 RegisterLocale=function(_,locale,values) translations[locale]=values; return {ok=true} end,
 TranslateLocale=function(_,source,key)
  assert(source==0)
  if fail then error('provider unavailable') end
  return {ok=true,value=translations[lang] and translations[lang][key] or ('Translation ['..lang..']['..key..'] does not exist')}
 end
}}
dofile('client/locale.lua'); dofile('translations/en_us.lua'); dofile('shared/hair_catalog.lua')
local english=translations.en_us
local styles,colors=0,0
for key in pairs(english) do
 if key:match('^character%.hair%.color%.') then colors=colors+1 end
 if key:match('^character%.hair%.male%.') or key:match('^character%.hair%.female%.') or key:match('^character%.beard%.male%.') then styles=styles+1 end
end
assert(styles==80 and colors==17)
for _,model in ipairs({'mp_male','mp_female'}) do
 for _,kind in ipairs({'hair','beard'}) do
  for index,group in ipairs(CharacterV2HairCatalog.Groups(model,kind)) do
   local label=CharacterV2HairCatalog.StyleLabel(group[1],index)
   assert(label:match(' %d+$'),label)
   assert(not label:match('^Style ') and not label:match('^Beard %d+$'),
    'reviewed hair and facial-hair styles must have descriptive names')
  end
 end
end
-- A name can change without changing identifiers or storing the number in translations.
local hash=96942958
local before=CharacterV2HairCatalog.Groups('mp_male','hair')[4][1]
assert(english['character.hair.male.004']=='Center Part')
assert(CharacterV2HairCatalog.StyleLabel(hash,4)=='Center Part 04')
CharacterV2Locale.Register('test', {['character.hair.male.004']='Part 100%', ['character.hair.color.blonde']='Test blonde'})
lang='test'
assert(CharacterV2HairCatalog.StyleLabel(hash,4)=='Part 100% 04')
assert(CharacterV2Locale.Text('character.hair.color.blonde')=='Test blonde')
assert(CharacterV2Locale.Text('character.hair.color.brown')=='Brown','partial locale falls back to English')
assert(CharacterV2Locale.Text('character.hair.none')=='None')
lang='missing'; assert(CharacterV2HairCatalog.StyleLabel(hash,4)=='Center Part 04')
fail=true; assert(CharacterV2HairCatalog.StyleLabel(hash,4)=='Center Part 04')
assert(CharacterV2HairCatalog.Groups('mp_male','hair')[4][1]==before)
assert(#CharacterV2HairCatalog.Groups('mp_female','beard')==0)
print('PASS hair locale: 80 style keys, 17 colors, names plus stable numbers, Core locale, partial/missing/unavailable fallback, identifier/filter preservation')
