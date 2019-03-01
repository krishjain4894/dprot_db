from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from .models import CustomUser
from .models import Experiment

class CustomUserCreationForm(UserCreationForm):

    class Meta(UserCreationForm):
        model = CustomUser
        fields = ('username', 'email')

class CustomUserChangeForm(UserChangeForm):

    class Meta:
        model = CustomUser
        fields = ('username', 'email')
        #fields = UserChangeForm.Meta.fields


class CustomExperimentCreationForm(forms.ModelForm):

    class Meta:
        model = Experiment
        fields = ('name', 'cell_line', 'treatment','user','fileurl','status','published_date')

    def __init__(self, request, *args, **kwargs):
        super(CustomExperimentCreationForm, self).__init__(*args, **kwargs)
        instance = getattr(self, 'instance', None)
        self.fields['published_date'].widget.attrs['readonly'] = True
        self.fields['status'].widget.attrs['readonly'] = True
        self.fields['user'].widget.attrs['value'] = request.user
        self.fields['user'].widget.attrs['readonly'] = True