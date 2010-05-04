module Fog
  module Parsers
    module Terremark
      module Shared

        class Vapp < Fog::Parsers::Base

          def reset
            @response = { 'Links' => [], 'disks' => []}
            @inside_os_section = false
            @inside_item = false
            @get_cpu = false
            @get_ram = false
            @get_disks = false
          end
 
          def start_element(name, attributes)
            @value = ''
            case name
              when 'Link'
                link = {}
                until attributes.empty?
                  link[attributes.shift] = attributes.shift
                end
                @response['Links'] << link
              when 'OperatingSystemSection'
                @inside_os_section = true
             when 'VApp'
                vapp = {}
                until attributes.empty?
                  if attributes.first.is_a?(Array)
                    attribute = attributes.shift
                    vapp[attribute.first] = attribute.last
                  else
                    vapp[attributes.shift] = attributes.shift
                  end
                end
                @response.merge!(vapp.reject {|key,value| !['href', 'name', 'size', 'status', 'type'].include?(key)})
             when 'Item'
                @inside_item = true
             end
          end

          def end_element(name)
            case name
              when 'IpAddress'
                @response['IpAddress'] = @value
              when 'Description'
                if @inside_os_section
                  @response['os'] = @value
                  @inside_os_section = false
                end
              when 'ResourceType'
                if @inside_item
                    case @value
                      when '3' 
                        @get_cpu = true # cpu
                      when '4'  # memory
                        @get_ram = true
                      when '17' # disks
                        @get_disks = true
                    end   
                end
              when 'VirtualQuantity'
                if (@get_cpu)
                  @response['cpu'] = @value
                  @get_cpu = false
                elsif (@get_ram)                
                  @response['ram'] = @value
                  @get_ram = false
                elsif (@get_disks)
                  @response['disks'] << @value  
                  @get_disks = false
                end
              when 'Item'
                @inside_item = false
            end
            
          end

        end

      end
    end
  end
end

