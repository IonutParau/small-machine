TextureManager = {}
TextureManager.tex = {}

---@param key string
---@param img string
function TextureManager:Cache(key, img)
    if self.tex[key] then return end

    self.tex[key] = {}
    local limg = love.graphics.newImage(img)
    self.tex[key].img = limg
    self.tex[key].size = {}
    self.tex[key].size.w = limg:getWidth()
    self.tex[key].size.h = limg:getHeight()
    self.tex[key].size.w2 = limg:getWidth()/2
    self.tex[key].size.h2 = limg:getHeight()/2
end

---@param key string
---@return love.Image?
function TextureManager:ImageFromCache(key)
    if self.tex[key] then return self.tex[key].img end
end

---@param key string
---@return {w: number, h: number, w2: number, h2: number}?
function TextureManager:SizeFromCache(key)
    if self.tex[key] then return self.tex[key].size end
end

---@param img string
function TextureManager:Load(img)
    if not self.tex[img] then
        self:Cache(img, img)
    end

    return self:ImageFromCache(img)
end