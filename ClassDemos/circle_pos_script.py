# Default values
import numpy as np

if 'n_positions' not in locals():
    n_positions = 12;
if 'radius' not in locals():
    radius = 5

def cart_to_pol(x, y):
    rho = np.sqrt(x**2 + y**2)
    theta = np.arctan2(y, x)
    return theta, rho

def pol_to_cart(theta, rho):
    x = rho * np.cos(theta)
    y = rho * np.sin(theta)
    return x, y    

theta = np.linspace(0, np.pi*2, n_positions, endpoint=False)
x, y = pol_to_cart(theta, radius)

circle_points = np.vstack((x, y)).T

print(circle_points)