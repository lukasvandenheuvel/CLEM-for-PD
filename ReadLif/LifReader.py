from readlif.reader import LifFile
from skimage import io
import utils
import pandas as pd
import numpy as np
import os

class LifReader():
    def __init__(self,path):
        # Read file
        self.lif = LifFile(path)
        self.layout = None
        self.tile_grid = None
        print(f'Loaded {self.lif.num_images} images in {path}')
        print('Image names:')
        for f in range(self.lif.num_images):
            img = self.lif.get_image(f)
            print(f'Img {f}: {img.name}, dims = ({img.dims.y} x {img.dims.x} x {img.dims.z} x {img.dims.t} x {img.dims.m})  scale = {img.scale} px/um')

    def read_layout(self,layout_path):
        self.layout = pd.read_excel(layout_path, header=None).to_numpy()
        self.tile_grid = utils.layout_to_grid(self.layout)

    def save_zstack(self,f,output_path,t=0,channels=[0,1,2,3,4]):
        img = self.lif.get_image(f)
        # Make folder to save tiles
        tiles_path = os.path.join(output_path, img.name)
        if not(os.path.exists(tiles_path)):
             os.mkdir(tiles_path)
             print('Made new tile folder')

        for m in range(img.dims.m):
            print(f'Starting tile {m+1} out of {img.dims.m}...')
            for ch in channels:
                # If image is a tile scan, obtain the m and c
                # if (img.dims.m > 1): # image is a scan
                #     assert(not(self.tile_grid is None)), 'First run read_layout before you can save zstack for this image!'
                #     row,col = [arr[0] for arr in np.where(self.tile_grid == tile_nr)]
                #     m,c = utils.find_m_and_c(img,self.tile_grid,row=row,col=col,ch=ch)
                # else: # image is not a tilescan
            
                print(f'Starting channel {ch+1} out of {len(channels)}...')
                for z in range(img.dims.z):
                    img_name = f'm{m:03d}_ch{ch:02d}_z{z:03d}.tif'
                    frame = np.array(img.get_frame(z=z,t=t,c=ch,m=m))
                    io.imsave(os.path.join(tiles_path,f'{img_name}'), frame, check_contrast=False)
                    print(f'Saved img {img_name}')

    def save_tiles_for_stitching(self,f,output_path,z='max',t=0,channels=[0,1,2,3,4],percentage_overlap=0.1):

        assert(not(self.tile_grid is None)), 'First run read_layout before you can save tiles for stitching!'
        img = self.lif.get_image(f)
        if not(type(z)==str):
            z = int(z)

        # Make folder to save tiles
        tiles_path = os.path.join(output_path, 'tiles')
        if not(os.path.exists(tiles_path)):
            os.mkdir(tiles_path)
            print('Made new tile folder')

        # Calculate tile coordinates and save them
        string = '# Define the number of dimensions we are working on\ndim = 2\n\n# Define the image coordinates\n'
        for row,grid_line in enumerate(self.tile_grid):
            for col,img_nr in enumerate(grid_line):
                if np.isnan(img_nr):
                    continue
                # Get tile coordinate
                x_coord  = col * (1-percentage_overlap)*img.dims.x
                y_coord  = row * (1-percentage_overlap)*img.dims.y
                img_name = f's{int(img_nr)}_z{z}.tif'
                string   = string + img_name + f'; ; ({x_coord}, {y_coord})\n'
        # Save tile coordinates
        with open(os.path.join(tiles_path,'TileConfiguration.txt'), 'w') as text_file:
            text_file.write(string)

        # Get tiles and save them
        for ch in channels:
            print(f'Starting channel {ch}')
            # Make folder to save tiles
            channel_path = os.path.join(tiles_path, f'ch{ch}_sfused_z{z}')
            if not (os.path.exists(channel_path)):
                os.mkdir(channel_path)
                print('Made new channels folder')
            else:
                print('Overwriting existing tiles')

            for row,grid_line in enumerate(self.tile_grid):
                for col,img_nr in enumerate(grid_line):
                    if np.isnan(img_nr):
                        continue
                    m,c = utils.find_m_and_c(img,self.tile_grid,row=row,col=col,ch=ch)
                    img_name = f's{int(img_nr)}_z{z}.tif'

                    # Obtain frame
                    if z=='max':
                        zstack = np.zeros((img.dims.z,img.dims.y,img.dims.x),dtype=np.int16)
                        for z_value in range(img.dims.z):
                            zstack[z_value,:,:] = np.array(img.get_frame(z=z_value, t=t, c=c, m=m))
                        frame = zstack.max(axis=0)
                    else:
                        frame = np.array(img.get_frame(z=z,t=t,c=c,m=m),dtype=np.int16)
                    
                    # Save Tif file
                    io.imsave(os.path.join(channel_path,f'{img_name}'), frame)
                    print(f'Saved img {img_name}')
        print('All tiles are saved!')