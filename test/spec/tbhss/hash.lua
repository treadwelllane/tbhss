local test = require("santoku.test")
local util = require("tbhss.util")
local hash = require("tbhss.hash")
local bm = require("santoku.bitmap")
local arr = require("santoku.array")

test("simhash", function ()

  local sentences = {
    { original = "The quick brown fox" },
    { original = "The brown quick fox" },
    { original = "A quick brown fox" },
    { original = "A brown quick fox" },
    { original = "The quick brown cat" },
    { original = "The brown quick cat" },
    { original = "The speedy brown fox" },
    { original = "The quick green fox" },
    { original = "The speedy brown cat" },
    { original = "The speedy green cat" },
  }

  local ids = {}
  local next_id = 1

  for i = 1, #sentences do
    sentences[i].split = util.split(sentences[i].original)
    sentences[i].tokens = {}
    sentences[i].positions = {}
    for j = 1, #sentences[i].split do
      local word = sentences[i].split[j]
      local id = ids[word]
      if not id then
        id = next_id
        ids[word] = next_id
        next_id = next_id + 1
      end
      arr.push(sentences[i].tokens, id)
      arr.push(sentences[i].positions, #sentences[i].tokens)
    end
  end

  local similarities = {
    [ids.the] = 1,
    [ids.a] = 1,
    [ids.quick] = 1,
    [ids.speedy] = 1,
    [ids.brown] = 1,
    [ids.green] = 1,
    [ids.fox] = 1,
    [ids.cat] = 1,
  }

  local scores = {
    [ids.the] = 5,
    [ids.a] = 5,
    [ids.quick] = 6,
    [ids.speedy] = 6,
    [ids.brown] = 7,
    [ids.green] = 7,
    [ids.fox] = 8,
    [ids.cat] = 8,
  }

  local bits
  local dimensions = 32
  local buckets = 400
  local wavelength = 4096

  for i = 1, #sentences do
    local raw
    raw, bits = hash.simhash(
      sentences[i].tokens,
      sentences[i].positions,
      similarities,
      scores,
      dimensions,
      buckets,
      wavelength)
    sentences[i].fingerprint = bm.from_raw(raw)
  end

  print()
  print(sentences[1].original)
  for i = 2, #sentences do
    local dist = bm.hamming(sentences[1].fingerprint, sentences[i].fingerprint) / bits
    print(string.format("%s\t%f\t%s", sentences[i].original, dist,
      "" or bm.tostring(sentences[i].fingerprint)))
  end

end)

-- test("position", function ()
--   print()
--   local str = require("santoku.string")
--   local positions = 40
--   local dimensions = 8
--   local buckets = 100
--   local precision = 5
--   for position = 1, positions do
--     str.printf("%2d: ", position)
--     for dimension = 1, dimensions do
--       str.printf("%4d ", hash.position(position, dimension, buckets, precision))
--     end
--     str.printf("\n")
--   end
-- end)
