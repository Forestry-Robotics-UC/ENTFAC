import re
import sys

def extract_projection_matrix(text, camera_name):
    pattern = rf'\[{camera_name}\]\n(?:.*\n)+?projection\n((?:[\d\.\-\s]+\n)+)'
    match = re.search(pattern, text, re.DOTALL)
    if match:
        matrix_str = match.group(1).strip().splitlines()
        matrix = [list(map(float, row.split())) for row in matrix_str]
        print(f"Extracted projection matrix for {camera_name}:")
        for row in matrix:
            print(row)
        return matrix
    else:
        print(f"Failed to extract projection matrix for {camera_name}.")
    return None

def compute_baseline(left_projection, right_projection):
    focal_length = left_projection[0][0]
    Tx = right_projection[0][3]
    print(f"Focal length (from left projection matrix): {focal_length}")
    print(f"Tx (translation component from right projection matrix): {Tx}")
    baseline = -Tx / focal_length
    print(f"Computed baseline: {baseline}")
    return baseline

def read_file(filename):
    with open(filename, 'r') as file:
        return file.read()

def main():
    if len(sys.argv) != 2:
        print("Usage: python compute_baseline.py <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]
    text = read_file(filename)
    
    left_projection = extract_projection_matrix(text, 'narrow_stereo/left')
    right_projection = extract_projection_matrix(text, 'narrow_stereo/right')
    
    if left_projection and right_projection:
        baseline = compute_baseline(left_projection, right_projection)
        print(f"Baseline between the cameras: {baseline:.6f} units")
    else:
        print("Could not find projection matrices for both cameras.")

if __name__ == "__main__":
    main()
