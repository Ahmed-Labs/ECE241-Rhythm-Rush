import sys
from PIL import Image

def main(image_name):
    image = Image.open(image_name, 'r')

    # Convert image to RGB if it's not already
    if image.mode != 'RGB':
        image = image.convert('RGB')

    pixels = list(image.getdata())
    print(pixels[0])

    mif_name = image_name.split('.')[0] + '.mif'

    with open(mif_name, 'w+') as mif_file:
        mif_file.write(f'DEPTH={len(pixels)};\nWIDTH=3;\nADDRESS_RADIX=DEC;\nDATA_RADIX=BIN;\nCONTENT\nBEGIN\n\n')
        
        for i in range(image.size[1]):
            mif_file.write(f"{i * image.size[0]}: ")
            for j in range(image.size[0]):
                pixel_index = i * image.size[0] + j
                mif_file.write(' ' + three_bit_conversion(pixels[pixel_index]))
            mif_file.write(';\n')

        mif_file.write('END;\n')

    image.close()

def three_bit_conversion(rgb):
    bits = []
    # print(rgb)
    # print(type(rgb))
    three_bit_value = rgb_to_3bit_per_pixel(rgb)
    print(bin(three_bit_value)[2:].zfill(9))
    for value in rgb:  # Only take the first three values (RGB)
        bits.append('1' if value > 125 else '0')
    return bin(three_bit_value)[2:].zfill(9)

def rgb_to_3bit_per_pixel(rgb):
    # Normalize the RGB values to the range 0-7
    normalized_rgb = [int(x * 7 / 255) for x in rgb]

    # Convert each normalized value to a 3-bit representation
    three_bit_repr = ((normalized_rgb[0] & 0b111) << 6) | ((normalized_rgb[1] & 0b111) << 3) | (normalized_rgb[2] & 0b111)

    return three_bit_repr

if __name__ == '__main__':
    for arg in sys.argv[1:]:
        main(arg)
