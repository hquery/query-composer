# For the query building UI, we need to store and load defined variables about patients that are made visible via the Patient API.
# The values below are made accessible through the Variables model that will use this file.

HQUERY_VARIABLES = {
  :demographics => {
    :long_name => 'Demographics',
    :short_name => 'Demographics',
    :icon => 'demographics.png',
    :options => [
      {
        :id => 'age',
        :long_name => 'Age',
        :short_name => 'Age',
        :title => 'Age is ',
        :input => {
          :type => 'range',
          :default_min => '0',
          :default_max => '85'
        }
      },
      {
        :id => 'education',
        :long_name => 'Education',
        :short_name => 'Education',
        :title => "Highest level of education achieved is ",
        :input => {
          :type => 'select',
          :default => 'All',
          :values => [
            { :long_name => 'All', :short_name => 'All' },
            { :long_name => 'None', :short_name => 'None' },
            { :long_name => 'High school', :short_name => 'HS' },
            { :long_name => 'College', :short_name => 'College' },
            { :long_name => 'Graduate School', :short_name => 'Grad School' }
          ]
        }
      },
      {
        :id => 'ethnicity',
        :long_name => 'Ethnicity',
        :short_name => 'Ethnicity',
        :title => "Ethnicity is ",
        :input => {
          :type => 'select',
          :default => 'All',
          :values => [
            { :long_name => 'All', :short_name => 'All' },
            { :long_name => 'White', :short_name => 'White' },
            { :long_name => 'Black', :short_name => 'Black' },
            { :long_name => 'Asian', :short_name => 'Asian' },
            { :long_name => 'Hispanic', :short_name => 'Hispanic' },
            { :long_name => 'Native American', :short_name => 'Native American' },
            { :long_name => 'Other', :short_name => 'Other' }
          ]
        }
      },
      {
        :id => 'language',
        :long_name => 'Language',
        :short_name => 'Language',
        :title => "Primarily language is ",
        :input => {
          :type => 'select',
          :default => 'All',
          :values => [
            { :long_name => 'All', :short_name => 'All' },
            { :long_name => 'English', :short_name => 'English' },
            { :long_name => 'Spanish', :short_name => 'Spanish' },
            { :long_name => 'Chinese', :short_name => 'Chinese' },
            { :long_name => 'Other', :short_name => 'Other' }
          ]
        }
      },
      {
        :id => 'disability',
        :long_name => 'Disability',
        :short_name => 'Disability',
        :title => "Disabilities: ",
        :input => {
          :type => 'select',
          :default => 'None',
          :values => [
            { :long_name => 'Both', :short_name => 'Both' },
            { :long_name => 'Mental', :short_name => 'Mental' },
            { :long_name => 'Physical', :short_name => 'Physical' },
            { :long_name => 'None', :short_name => 'None' }
          ]
        }
      },
      {
        :id => 'gender',
        :long_name => 'Gender',
        :short_name => 'Gender',
        :title => "",
        :input => {
          :type => 'select',
          :default => 'All',
          :values => [
            { :long_name => 'All', :short_name => 'All' },
            { :long_name => 'Male', :short_name => 'M' },
            { :long_name => 'Female', :short_name => 'F' }
          ]
        }
      },
      {
        :id => 'insurance',
        :long_name => 'Insurance',
        :short_name => 'Insurance',
        :title => "Insurance provider is ",
        :input => {
          :type => 'select',
          :default => 'All',
          :values => [
            { :long_name => 'All', :short_name => 'All' },
            { :long_name => 'Blue Cross Blue Shield', :short_name => 'BCBS' }
          ]
        }
      },
      {
        :id => 'marital_status',
        :long_name => 'Marital Status',
        :short_name => 'Marital Status',
        :title => "",
        :input => {
          :type => 'select',
          :default => 'All',
          :values => [
            { :long_name => 'All', :short_name => 'All' },
            { :long_name => 'Single', :short_name => 'Single' },
            { :long_name => 'Married', :short_name => 'Married' }
          ]
        }
      }
    ]
  },
  
  :health_history => {
    :long_name => '',
    :short_name => '',
    :icon => '',
    :options => [
      {
        :long_name => '',
        :short_name => '',
        :parameters => [
          {
            :type => '',
            :default => '',
            :values => [
              
            ]
          }
        ]
      },
      {
        
      }
    ]
  },
  
  :condition => {
    :long_name => '',
    :short_name => '',
    :icon => '',
    :options => [
      {
        :long_name => '',
        :short_name => '',
        :parameters => [
          {
            :type => '',
            :default => '',
            :values => [
              
            ]
          }
        ]
      },
      {
        
      }
    ]
  },
  
  :observations => {
    :long_name => '',
    :short_name => '',
    :icon => '',
    :options => [
      {
        :long_name => '',
        :short_name => '',
        :parameters => [
          {
            :type => '',
            :default => '',
            :values => [
              
            ]
          }
        ]
      },
      {
        
      }
    ]
  },
  
  :treatment => {
    :long_name => '',
    :short_name => '',
    :icon => '',
    :options => [
      {
        :long_name => '',
        :short_name => '',
        :parameters => [
          {
            :type => '',
            :default => '',
            :values => [
              
            ]
          }
        ]
      },
      {
        
      }
    ]
  }
}