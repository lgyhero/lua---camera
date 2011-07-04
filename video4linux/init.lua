
----------------------------------
-- dependencies
----------------------------------
require 'torch'
require 'xlua'
require 'image'
require 'libv4l'

----------------------------------
-- a camera class
----------------------------------
local Camera = torch.class('image.Camera')

function Camera:__init(...)
   -- parse args
   local args, idx, nbuffers, fps = xlua.unpack(
      {...},
      'ImageSource', help_desc,
      {arg='idx', type='number', help='camera index', default=0},
      {arg='buffers', type='number', help='number of buffers (v4l2 only)', default=1},
      {arg='fps', type='number', help='optional frame rate (v4l2 only)', default=30}
   )
   -- init vars
   self.camidx = '/dev/video'..(idx or 0)
   self.nbuffers = nbuffers
   self.fps = fps
   self.tensor = torch.Tensor(3,480,640)
end

function Camera:forward(tensor)
   libv4l.grabFrame(self.tensor, self.camidx, self.nbuffers, self.fps)
   if tensor then
      image.scale(self.tensor,tensor)
   else
      tensor = self.tensor
   end
   return tensor
end

function Camera:stop()
   print('stopping camera')
end