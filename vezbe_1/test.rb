require_relative 'session_manager'
require_relative 'table'
session = SessionManager.new("config.json")

t = session.get_worksheet('1FjwQyq-SSvhUqHrEr6CBhH60Np2_rQDxWfGYLIVPOW8')
t2 = session.get_worksheet('1elExxapCE0FS1FXa_6Bni-W5GQb41-lwpqfXslW5f4w')
p t.index.sum
t.ime[0] = 'Natasa'
p t.sync()

p t + t2

p t - t2




