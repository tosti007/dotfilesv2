#!/usr/bin/env python
# Settings for background generation

# A seed to ensure that we get the same image every time
seed = 1234

# The colors ids as defined by pywal.
# Each tuple represents a combination of colors.
# A random tuple will be picked for each floppy.
# Using x0+x1+...+xn will result in the average of the listed colors.
colors = [
    ('12', '14+10', '11', '9'),
    ('14+10', '9', '12', '11'),
    ('11', '12', '9', '14+10'),
]

# Location and size settings
# Each setting is explained by the comment after it.
# All floppys will be placed on the center of the screen.
main = {
    'width': 1920, # Output image width
    'height': 1080, # Output image height
    'angle': 45, # Rotation angle of the floppys
    'transform_x': 0, # Transform x distance
    'transform_y': 0, # Transform y distance
    'nx': 12, # Number of floppys in x direction
    'ny': 12, # Number of floppys in the y direction
    'scale': 1.5, # Scale to resize each floppy with
    'margin': 50 # Margin around each floppy, does not overlap.
}
