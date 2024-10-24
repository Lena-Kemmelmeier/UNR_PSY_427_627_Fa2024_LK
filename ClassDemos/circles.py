# Default values
import numpy as np

def cart_to_pol(x, y):
    rho = np.sqrt(x**2 + y**2)
    theta = np.arctan2(y, x)
    return theta, rho

def pol_to_cart(theta, rho):
    x = rho * np.cos(theta)
    y = rho * np.sin(theta)
    return x, y    


def circle_pos(n_positions, radius = 5):
    """define `n_positions` along a circle"""
    theta = np.linspace(0, np.pi*2, n_positions, endpoint=False)
    x, y = pol_to_cart(theta, radius)
    circle_points = np.vstack((x, y)).T
    return