import pyedflib

def get_annotations(file_path):
    # Open BDF file
    print("Opening BDF file:", file_path)
    f = pyedflib.EdfReader(file_path)

    # Extract annotations
    print("Reading annotations...")
    annotations = f.readAnnotations()
    print("Annotations read successfully.")
    
    # Close the file
    f.close()
    print("BDF file closed.")
    
    return annotations

file_path = 'Matlab_scripts/444931.bdf'
annotations = get_annotations(file_path)

# Check if annotations are empty
if not annotations[0].size:
    print("No annotations found.")
else:
    # Print annotations
    print("Printing annotations...")
    for i, (onset, duration, description) in enumerate(zip(annotations[0], annotations[1], annotations[2])):
        try:
            decoded_description = description.decode()
            print(f"Annotation {i}: Onset: {onset}, Duration: {duration}, Description: {decoded_description}")
        except Exception as e:
            print(f"Error decoding description for annotation {i}: {e}")
            print(f"Raw description: {description}")
