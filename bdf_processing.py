import pyedflib 
import numpy as np 
import pandas as pd 


def read_bdf(file_path): 
    #open BDF file 
    f = pyedflib.EdfReader(file_path)
    # number of signals/channels in the file
    n = f.signals_in_file 
    # extract signal labels
    signal_labels = f.getSignalLabels()
    signal_data = [] 
    for i in range(n):
        signal_data.append(f.readSignal(i))
    annotations = f.readAnnotations()
    f.close() 
    return signal_labels, signal_data, annotations

def save_samples(signal_data, signal_labels, annotations, sample_duration=10, step_size=5, file_prefix='sample'):
    data_array = np.array(signal_data).T
    df = pd.DataFrame(data_array, columns=signal_labels)

    sampling_rate = 2048 
    samples_per_segment = sampling_rate * sample_duration 
    step_samples = sampling_rate * step_size 
    
    conditions =  {
        '60': 'Eyes Closed Start',
        '61': 'Eyes Closed End',
        '62': 'Eyes Open Start',
        '63': 'Eyes Open End',
        '64': 'Boredom Start',
        '65': 'Boredom End',
        '66': 'Interest Start',
        '67': 'Interest End'
    }

    segments = []
    labels = [] 

    print("Annotations:")
    for i, (onset, duration, description) in enumerate(zip(annotations[0], annotations[1], annotations[2])):
        marker = int(description)
        condition = conditions.get(marker, None)
        print(f"Annotation {i}: onset={onset}, duration={duration}, description={description} ({condition})")

        if condition and "Start" in condition:
            start_index = int(onset * sampling_rate)
            if i + 1 < len(annotations[0]):
                next_onset = annotations[0][i + 1]
                end_index = int(next_onset * sampling_rate)
            else:
                end_index = len(df)
            
            print(f"Processing {condition}: start_index={start_index}, end_index={end_index}, samples_per_segment={samples_per_segment}, step_samples={step_samples}")
            
            for j in range(start_index, end_index - samples_per_segment + 1, step_samples):
                segment = df.iloc[j:j+samples_per_segment]
                if len(segment) == samples_per_segment:
                    segment_file = f'{file_prefix}_{len(segments)}.npy'
                    np.save(segment_file, segment.values)
                    segments.append(segment_file)
                    
                    if "Boredom" in condition:
                        labels.append("Boredom")
                    elif "Interest" in condition:
                        labels.append("Interest")
                    else:
                        labels.append("Eyes Open/Closed")
                    print(f"Saved segment {len(segments)} with label {labels[-1]}")
    
    with open(f'{file_prefix}_labels.txt', 'w') as label_file:
        for segment, label in zip(segments, labels):
            label_file.write(f'{segment},{label}\n')
    
    print(f'Saved {len(segments)} segments with labels.')
#def save_to_csv(signal_data, signal_labels, file_name='output.csv'):
    # convert signal data to a numpy array 
    #data_array = np.array(signal_data).T 

    #create DataFrame from the numpy array 
    #df = pd.DataFrame(data_array, columns=signal_labels)    

    # save the DataFrame to  a CSV file
    #df.to_csv(file_name, index=False)
    #print(f'Data saved to {file_name}')

if __name__ == "__main__":
    file_path = 'Matlab_scripts/444931.bdf'
    signal_labels, signal_data, annotations = read_bdf(file_path)
    save_samples(signal_data, signal_labels, annotations, sample_duration=10, step_size=5, file_prefix='sample')


