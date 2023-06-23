import numpy as np

def grid_to_count(row,col,shape=[16,48],mode='row-by-row'):
    # Returns the count corresponding to a specified row and column.
    # Example for a 4x3 pattern, imaging_mode='snaking':
    # [[0,1,2],
    #  [5,4,3],
    #  [6,7,8],
    #  [11,10,9]]
    num_rows,num_cols = shape
    assert ((row<num_rows) and (col<num_cols)), f"Invalid row {row} and column {col} for a chip of shape {num_rows}x{num_cols}!"
    if mode ==  'row-by-row':
        count = row*num_cols + col
    elif mode ==  'snaking':
        if (row%2 == 0):  # even row number (0,2,4,...)
            count = row*num_cols + col
        else:
            count = (row+1)*num_cols - col-1
    else:
        raise ValueError("imaging_mode must be 'row-by-row' or 'snaking'")
    return count

def count_to_grid(count,shape=[16,48],mode='row-by-row'):
    # Returns the row and the column corresponding to image nr #count.
    # count corresponds to the order in which the images are taken.
    # Example for a 4x3 pattern, imaging_mode='row-by-row':
    # [[0,1,2],
    #  [3,4,5],
    #  [6,7,8],
    #  [9,10,11]]
    num_rows,num_cols = shape
    assert ((count >= 0)&(count < num_rows*num_cols)), f"Invalid count {count} for a chip of shape {num_rows}x{num_cols}!"
    # Row-by-row pattern
    if mode ==  'row-by-row':
        row = count // num_cols
        col = count%num_cols
    # Snaking pattern
    elif mode ==  'snaking':
        # which row are we in?
        row = count // num_cols
        # corresponding column:
        if (row%2 == 0):  # even row number (0,2,4,...)
            col = count%num_cols
        else:             # uneven row number (1,3,5,...)
            col = num_cols - 1 - count%num_cols
    else:
        raise ValueError("imaging_mode must be 'row-by-row' or 'snaking'")
    return row,col

def layout_to_grid(tile_layout):
    # Takes as input a tile layout, and outputs the order in which the images
    # were taken.
    grid = np.empty(tile_layout.shape)
    grid.fill(np.nan)
    tile_count = 0

    for nr in range(tile_layout.shape[0]*tile_layout.shape[1]):
        row,col = count_to_grid(nr,shape=tile_layout.shape,mode='snaking')
        if ~np.isnan(tile_layout[row,col]):
            grid[row,col]   = int(tile_count)
            tile_count      = tile_count + 1
    return grid

def find_row_and_column_and_channel(img,tile_grid,c=0,m=0):
    # From a c and m number (in LIF file), output the REAL row, column and channel.
    num_tiles = np.nanmax(tile_grid) + 1
    ch      = (m*img.channels + c) // num_tiles
    img_nr  = (m*img.channels + c) % num_tiles
    row,col = [arr[0] for arr in np.where(tile_grid == img_nr)]
    return row,col,ch

def find_m_and_c(img,tile_grid,row=0,col=0,ch=0):
    # From REAL row, column and channel, output the LIF m and c values.
    assert(not np.isnan(tile_grid[row,col])), "No image was taken at this position in the tile layout!"
    num_tiles = np.nanmax(tile_grid) + 1
    img_nr = tile_grid[row,col]
    m = (ch*num_tiles + img_nr) // img.channels
    c = (ch*num_tiles + img_nr) % img.channels
    return int(m),int(c)
