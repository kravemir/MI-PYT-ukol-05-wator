# MI-PYT-ukol-05-wator

Run code:

```bash
# clone repository
git clone --recursive git@github.com:kravemir/MI-PYT-ukol-05-wator.git
cd MI-PYT-ukol-05-wator

# create and activate virtual environment
python3.6 -m venv __venv__
. __venv__/bin/activate

# install dependencies
python -m pip install --upgrade pip wheel
pip install -r requirements.txt

# run tests
python3.6 -m pytest wator_tests/tests/

# run notebook
python -m jupyter notebook
```
