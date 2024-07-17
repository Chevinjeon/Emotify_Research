import mne

# Load the raw EEG data from the .bdf file
raw = mne.io.read_raw_bdf('processed_data.bdf', preload=True)

# Extract events (markers)
events = mne.find_events(raw)

# Print the events
print(events)

# Optionally, save the events to a text file
mne.write_events('events.txt', events)