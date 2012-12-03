{Database,Profile} = require '../fussy'
{extractLinks, fetchTitle} = require '../webutils'

tweets =
  """Interesting article on the epic battles between tech firms. How do you see these battles paving the path of the... http://t.co/b87tmKsY""": ["Technology","Law suits"]
  """RT @9to5mac: Apple announces iPhone 5 coming to South Korea & 50 more countries in December http://t.co/My5ShZJ3""": ["Apple", "iPhone","South Korea","Release","Technology"]
  """RT @RobertAlai: iPhone 5 Will Sell in Kenya from December 21, Apple Announces - http://t.co/SWM5balk via @techmtaa #fb""": ["Apple", "iPhone","Africa","Release","Technology"]
  """RT @CNET: Apple's Safari grabbed 61.5% of mobile browser usage in November, more than double that of Android's unbranded browser http://t.co/GnK5WuSE""": ["Apple","Mobile","Browser","Safari","Android","Technology"]
  """What would your "perfect day" look like? ISyE Prof. Pokutta researches concepts of optimization to maximize happiness.http://t.co/OBsbolsk""": ["Research", "Science", "Psychology"]
  """Skyrim: Dragonborn coming to PS3 and PC in 2013: Bethedsa has confirmed that it'll release Skyrim: Dragonborn fo... http://t.co/mpdaI0on""": ["Skyrim", "PS3", "Gaming", "Release", "Media"]
  """EU High Representative Ashton extremely concerned over Israeli plans to expand settlements - EU press release/No... http://t.co/4ToENrl8""": ["Israel", "War", "Ashton", "EU"]
  """RT @nytimes: Clinton Warns Syria Against Using Chemical Weapons http://t.co/mR7onXNx""": ["New York Times", "Bill Clinton", "Chemical Weapons", "Weapons", "War"]
  """RT @FastCompany: Today @Lara's @SyriaDeeply launches: an innovative news network dedicated to covering the crisis in Syria http://t.co/dD9W5uBC""": ["Syria", "Technology", "Journalism", "War"]
  """#NUTTY Obama Says No to Oil Leases, But Yes to Windmills, Off the Atlantic Coast | CNS News http://t.co/kyaJSJFP #tcot #ocra #p2""": ["Oil", "Obama", "Windmills", "Atlantic Coast", "United States"]
  """What the Fiscal Cliff Means For #Nonprofits http://t.co/hgksVAld #philanthropy via @COF_ @Vol_of_America""": ["Fiscality", "Taxes", "Fiscal Cliff", "Philantropy", "Non-Profit", "United States"]
  """Blgr: Royal palace confirms: Kate Middleton is pregnant! http://t.co/ChbaZz8d #moms""": ["Royal Family"," Babies", "Pregnancy", "United Kingdom"]
  """RT @WfWnews: Wonderful news!! @WfWnews awarded £468,000+ over 3 yrs by @Sport_England to develop an inclusive #cycling network for London! #SEinclusive""": ["United Kingdom", "London", "Biking", "Cycling", "Roads"]

if no
  filtered = {}
  for tweet, tags of tweets
    if extractLinks(tweet).length
      filtered[tweet] = tags
  tweets = filtered

module.exports = (new Database()).learn tweets